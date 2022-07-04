module Recorder
  def record(record : Record)
  end
end

class FileSystemRecorder
  include Recorder

  def initialize(@config : Config)
  end

  def record(record : Record) : Record
    index = record.index
    index_file_path = "#{@config.base_dir_path}/indexes/#{index}"
    File.write(index_file_path,record.index_conditions)
    reply_file_path = "#{@config.base_dir_path}/replies/#{index}"
    File.write(reply_file_path,record.body)
    record
  end
end
