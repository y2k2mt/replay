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
      #found = @config.indexer.request_match(context.request)
      call_next(context)
    end
  end
end
