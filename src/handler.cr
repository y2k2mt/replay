module Parrot
  class RecordingHandler
    include HTTP::Handler

    def initialize(@config : Config)
    end

    def call(context)
      context.request.headers["Host"] = @config.base_uri_host
      client_response = HTTP::Client.new(@config.base_uri).exec(context.request)
      index_or_die = @config.recorder.record(
        Index.new(context.request),
        Record.new(client_response)
      )
      context.response.headers.merge!(client_response.headers)
      context.response.puts client_response.body
    end
  end

  class RepeatingHandler
    include HTTP::Handler

    def initialize(@config : Config)
    end

    def call(context)
      requested_index = Index.new(context.request)
      found = @config.recorder.find(requested_index)
      found.try do |f|
        context.response.headers.merge!(f.headers)
        context.response.puts f.body
      end || (
        context.response.status_code = 404
        context.response.puts "Not recorded yet!"
      )
    end
  end
end
