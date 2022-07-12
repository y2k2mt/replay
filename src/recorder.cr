module Recorder
  def record(record : Record)
  end
end

class FileSystemRecorder
  include Recorder

  def initialize(@config : Config)
    @index_file_dir = "#{@config.base_dir_path}/indexes"
    @reply_file_dir = "#{@config.base_dir_path}/replies"
  end

  def record(index : Index, record : Record) : Record
    index_hash = index.index
    if (!File.directory?(@index_file_dir))
      Dir.mkdir_p(@index_file_dir)
    end
    File.open("#{@index_file_dir}/#{index_hash}", "w+")
    File.write("#{@index_file_dir}/#{index_hash}", index.index_conditions.to_pretty_json)

    if (!File.directory?(@reply_file_dir))
      Dir.mkdir_p(@reply_file_dir)
    end
    File.open("#{@reply_file_dir}/#{index_hash}_headers", "w+")
    File.write("#{@reply_file_dir}/#{index_hash}_headers", record.headers.to_h.to_json)
    File.open("#{@reply_file_dir}/#{index_hash}", "w+")
    File.write("#{@reply_file_dir}/#{index_hash}", record.body)
    record
  end

  record ApiResponse, params : Hash(String, Array(String)) do
    include JSON::Serializable
  end

  def find(index : Index) : Record?
    index_hash = index.index
    body_file = Dir["#{@reply_file_dir}/#{index_hash}"].first?
    header_file = Dir["#{@reply_file_dir}/#{index_hash}_headers"].first?
    if (header_file && body_file)
      response_headers = HTTP::Headers.new
      Hash(String, Array(String)).from_json(JSON.parse(File.read(header_file)).to_json).map do |k, v|
        response_headers[k] = v
      end
      response_body = File.read(body_file)
      Record.new(response_headers, response_body)
    else
      nil
    end
  end
end
