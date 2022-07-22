module Replay
  class RecordingHandler
    include HTTP::Handler

    def initialize(@config : Config)
    end

    def call(context)
      context.request.headers["Host"] = @config.base_uri_host
      Replay::Log.debug { "Recorder: sending client request : #{context.request}" }
      client_response = HTTP::Client.new(@config.base_uri).exec(context.request)
      Replay::Log.debug { "Recorder: recording client response : #{client_response}" }
      record_or_die = @config.recorder.record(
        Index.new(@config, context.request),
        Record.new(client_response)
      )
      Replay::Log.debug { "Recorder: client response recorded as : #{record_or_die[0].index}" }
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
      requested_index = Index.new(@config, context.request)
      Replay::Log.debug { "Repeater: request index : #{requested_index.index}" }
      found = @config.recorder.find(requested_index)
      Replay::Log.debug { "Repeater: request index is #{(found) ? "found" : "not found"} for #{requested_index.index}" }
      if found
        context.response.status_code = found.response_status
        context.response.headers.merge!(found.headers)
        context.response.puts found.body
      else
        context.response.status_code = 404
        context.response.puts "Not recorded yet!"
      end
    end
  end
end
