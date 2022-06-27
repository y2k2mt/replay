module Parrot
  class RecordingHandler
    include HTTP::Handler

    def initialize(@config : ServerConfig)
    end

    def call(context)
      uri = URI.parse(@config.base_url)
      uri.host.try do |host|
        context.request.headers["Host"] = host
      end
      client_response = HTTP::Client.new(uri).exec(context.request)
      #record = RequestRecord.new(context)
      #RequestRecords.recording(record)
      context.response.headers.merge!(client_response.headers)
      context.response.puts(client_response.body)
      context.response.flush
      #call_next(HTTP::Server::Context.new(context.request,response))
    end
  end

  class RepeatingHandler
    include HTTP::Handler

    def call(context)
      found = RequestRecords.request_match?(context)
      call_next(context)
    end
  end
end
