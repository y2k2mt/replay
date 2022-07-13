module Parrot
  class RecordingHandler
    include HTTP::Handler

    def initialize(@config : Config)
    end

    def call(context)
      context.request.headers["Host"] = @config.base_uri_host
      Parrot::Log.debug { "Recorder: sending client request : #{context.request}" }
      client_response = HTTP::Client.new(@config.base_uri).exec(context.request)
      Parrot::Log.debug { "Recorder: recording client response : #{client_response}" }
      record_or_die = @config.recorder.record(
        Index.new(context.request),
        Record.new(client_response)
      )
      Parrot::Log.debug { "Recorder: client response recorded as : #{record_or_die[0].index}" }
      context.response.headers.merge!(client_response.headers)
      context.response.puts client_response.body
    end
  end

  class RepeatingHandler
    include HTTP::Handler

    def initialize(@config : Config)
    end

    def call(context)
      context.request.headers["Host"] = @config.base_uri_host
      requested_index = Index.new(context.request)
      Parrot::Log.debug { "Repeater: request index : #{requested_index.index}" }
      found = @config.recorder.find(requested_index)
      Parrot::Log.debug { "Repeater: request index is #{(found) ? "found" : "not found"} for #{requested_index.index}" }
      if found
        # FIXME: fixed status code
        context.response.status_code = 200
        context.response.headers.merge!(found.headers)
        context.response.puts found.body
      else
        context.response.status_code = 404
        context.response.puts "Not recorded yet!"
      end
    end
  end
end
