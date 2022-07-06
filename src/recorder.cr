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
    index_file_dir = "#{@config.base_dir_path}/indexes"
    if(!File.directory?(index_file_dir))
      Dir.mkdir_p(index_file_dir)
    end
    File.open("#{index_file_dir}/#{index}","w+")
    File.write("#{index_file_dir}/#{index}",record.index_conditions.to_json)

    reply_file_dir = "#{@config.base_dir_path}/replies"
    if(!File.directory?(reply_file_dir))
      Dir.mkdir_p(reply_file_dir)
    end
    File.open("#{reply_file_dir}/#{index}","w+")
    File.write("#{reply_file_dir}/#{index}",record.body)
    record
  end
end
