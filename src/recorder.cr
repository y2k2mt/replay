module Recorder
  def record(indexer : Indexer,record : Record)
  end
end

class FileSystemRecorder
  include Recorder

  def record(indexer : Indexer,record : Record) : Record
    # TODO: impl
    record
  end
end
