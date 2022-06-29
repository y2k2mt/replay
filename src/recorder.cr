module Recorder
  def record(record : Record)
  end
end

class FileSystemRecorder
  include Recorder

  def record(record : Record) : Record
    #TODO: impl
    record
  end
end
