module Parrot
  class RecordingHandler
    include HTTP::Handler

    @base_uri : URI
    @base_uri_host : String

    def initialize(config : ServerConfig)
      @base_uri = config.base_url.try do |url|
        URI.parse(url)
      end || raise "Invalid configuration [base_url] : #{config.base_url}"
      @base_uri_host = @base_uri.host.try do |host|
          host
      end || raise "Invalid configuration [base_url] : #{config.base_url}"
    end

    def call(context)
      context.request.headers["Host"] = @base_uri_host
      client_response = HTTP::Client.new(@base_uri).exec(context.request)
      Records.recording(
        Record.new(@base_uri, context.request, client_response)
      )
      context.response.headers.merge!(client_response.headers)
      context.response.puts(client_response.body)
    end
  end

  class RepeatingHandler
    include HTTP::Handler

    def call(context)
      found = Records.request_match?(context)
      call_next(context)
    end
  end
end
