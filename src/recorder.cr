module Recorder
  def record(record : Record)
  end
end

class FileSystemRecorder
  include Recorder

  def initialize(@config : Config)
  end

  def record(record : Record) : Record
    index = record.create_index
    index_file_path = "#{@config.base_dir_path}/indexes/#{index.string}"
    File.write(index_file_path,index.conditions.to_json)
    reply_file_path = "#{@config.base_dir_path}/replies/#{index.string}"
    File.write(reply_file_path,record.body.to_json)
    record
  end
end
