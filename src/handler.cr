module Parrot
  class RecordingHandler
    include HTTP::Handler

    def call(context)
      record = RequestRecord.new(context)
      RequestRecords.recording(record)
      call_next(context)
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
