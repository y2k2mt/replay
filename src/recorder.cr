module Recorder
  def record(record : Record)
  end
end

class FileSystemRecorder
  include Recorder

  def initialize(@config : Config)
  end

  def record(index : Index, record : Record) : Record
    index_hash = index.index
    index_file_dir = "#{@config.base_dir_path}/indexes"
    if (!File.directory?(index_file_dir))
      Dir.mkdir_p(index_file_dir)
    end
    File.open("#{index_file_dir}/#{index_hash}", "w+")
    File.write("#{index_file_dir}/#{index_hash}", index.index_conditions.to_pretty_json)

    reply_file_dir = "#{@config.base_dir_path}/replies"
    if (!File.directory?(reply_file_dir))
      Dir.mkdir_p(reply_file_dir)
    end
    File.open("#{reply_file_dir}/#{index_hash}_headers", "w+")
    File.write("#{reply_file_dir}/#{index_hash}_headers", record.headers.to_h.to_json)
    File.open("#{reply_file_dir}/#{index_hash}", "w+")
    File.write("#{reply_file_dir}/#{index_hash}", record.body)
    record
  end

  def find(index : Index) : Record?
    #TODO: impl
    nil
  end
end
