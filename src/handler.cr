module Parrot
  class RecordingHandler
    include HTTP::Handler

    def initialize(@config : Config)
    end

    def call(context)
      context.request.headers["Host"] = @config.base_uri_host
      client_response = HTTP::Client.new(@config.base_uri).exec(context.request)
      index_or_die = @config.indexer.index(
        @config.recorder.record(
          Record.new(@config.base_uri, context.request, client_response)
        )
      )
      case index_or_die
      when Indexer::IndexError
        context.response.status = HTTP::Status::INTERNAL_SERVER_ERROR
        context.response.puts index_or_die.message
      else
        context.response.headers.merge!(client_response.headers)
        context.response.puts client_response.body
      end
    end
  end

  class RepeatingHandler
    include HTTP::Handler

    def initialize(@config : Config)
    end

    def call(context)
      found = @config.indexer.request_match(context.request)
      call_next(context)
    end
  end
end
