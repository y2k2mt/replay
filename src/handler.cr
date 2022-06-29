module Parrot
  class RecordingHandler
    include HTTP::Handler

    @base_uri : URI

    def initialize(@config : ServerConfig)
      @base_uri = URI.parse(@config.base_url).not_nil!
    end

    def call(context)
      context.request.headers["Host"] = @base_uri.host.not_nil!
      client_response = HTTP::Client.new(@base_uri).exec(context.request)
      RequestRecords.recording(
        RequestRecord.new(@base_uri,context.request,client_response)
      )
      context.response.headers.merge!(client_response.headers)
      context.response.puts(client_response.body)
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
