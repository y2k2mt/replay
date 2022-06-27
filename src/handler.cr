module Parrot
  class RecordingHandler
    include HTTP::Handler

    def initialize(@config : ServerConfig)
    end

    def call(context)

      response = HTTP::Client.new(@config.base_url).exec(context.request)
      record = RequestRecord.new(context)
      RequestRecords.recording(record)
      call_next(HTTP::Server::Context.new(context.request,response))
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
