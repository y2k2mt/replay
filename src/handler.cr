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
      client_response.to_io(context.response)
      #context.response.headers = client_response.headers
      #context.response.body = client_response.body
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
