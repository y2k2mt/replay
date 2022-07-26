module Recorder
  def record(record : Record) : Tuple(Index, Record)
  end

  def find(index : Index) : Record?
  end
end

class FileSystemRecorder
  include Recorder

  def initialize(@config : Config)
    @index_file_dir = "#{@config.base_dir_path}/indexes"
    @reply_file_dir = "#{@config.base_dir_path}/replies"
  end

  def record(index : Index, record : Record) : Tuple(Index, Record)
    index_hash = index.id_index
    if (!File.directory?(@index_file_dir))
      Dir.mkdir_p(@index_file_dir)
    end
    File.open("#{@index_file_dir}/#{index_hash}", "w+")
    File.write("#{@index_file_dir}/#{index_hash}", index.index_conditions.to_pretty_json)

    if (!File.directory?(@reply_file_dir))
      Dir.mkdir_p(@reply_file_dir)
    end

    record_headers_hash = record.headers.to_h
    record_headers_hash["response_status"] = [record.response_status.to_s]
    File.open("#{@reply_file_dir}/#{index_hash}_headers", "w+")
    File.write("#{@reply_file_dir}/#{index_hash}_headers", record_headers_hash.to_json)
    File.open("#{@reply_file_dir}/#{index_hash}", "w+")
    File.write("#{@reply_file_dir}/#{index_hash}", record.body)
    {index, record}
  end

  def find(index : Index) : Record?
    meta_index = index.meta_index
    index_files = Dir["#{@index_file_dir}/#{meta_index}_*"]
    if index_files.empty?
      Replay::Log.debug { "No index_file avairable." }
      nil
    else
      found_index_file = index_files.find do |index_file|
        index_candidate = Index.from(File.read(index_file))
        index_candidate.match?(index)
      end
      found_index_file.try do |found|
        found_index = Index.from(File.read(found))
        body_file = Dir["#{@reply_file_dir}/#{found_index.id_index}"].first?
        header_file = Dir["#{@reply_file_dir}/#{found_index.id_index}_headers"].first?
        if (header_file && body_file)
          Replay::Log.debug { "Found header_file path: #{header_file}" }
          Replay::Log.debug { "Found body_file path: #{body_file}" }
          response_headers = HTTP::Headers.new
          header_file_hash = Hash(String, Array(String)).from_json(File.read(header_file))
          header_file_hash.map do |k, v|
            if k != "response_status"
              response_headers[k] = v
            end
          end
          response_body = File.read(body_file)
          Replay::Log.debug { "Recorded response headers: #{response_headers}" }
          Record.new(response_headers, response_body, header_file_hash["response_status"].first.to_i32)
        else
          Replay::Log.debug { "No header_file and body_file avairable." }
          nil
        end
      end || (
        Replay::Log.debug { "index_file not matched any." }
        nil
      )
    end
  end
end