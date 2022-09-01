class FileSystemDatasource
  include Datasource

  def initialize(@config : Config)
    @index_file_dir = "#{@config.base_dir_path}/indexes"
    @reply_file_dir = "#{@config.base_dir_path}/replies"
  end

  def persist(request : Request, record : Record) : Record
    index_hash = request.id_index
    if (!File.directory?(@index_file_dir))
      Dir.mkdir_p(@index_file_dir)
    end
    File.open("#{@index_file_dir}/#{index_hash}", "w+")
    File.write("#{@index_file_dir}/#{index_hash}", request.metadatas.to_pretty_json)

    if (!File.directory?(@reply_file_dir))
      Dir.mkdir_p(@reply_file_dir)
    end

    File.open("#{@reply_file_dir}/#{index_hash}_headers", "w+")
    File.write("#{@reply_file_dir}/#{index_hash}_headers", record.metadatas.to_json)
    File.open("#{@reply_file_dir}/#{index_hash}", "w+")
    File.write("#{@reply_file_dir}/#{index_hash}", record.entity)
    record
  end

  def find(request : Request, requests : Requests) : Record?
    meta_index = request.base_index
    index_files = Dir["#{@index_file_dir}/#{meta_index}_*"]
    if index_files.empty?
      Replay::Log.debug { "No index_file avairable." }
      nil
    else
      found_index_file = index_files.find do |index_file|
        candidate = requests.from(JSON.parse(File.read(index_file)))
        candidate == request
      end
      found_index_file.try do |found|
        found_index = requests.from(JSON.parse(File.read(found)))
        body_file = Dir["#{@reply_file_dir}/#{found_index.id_index}"].first?
        header_file = Dir["#{@reply_file_dir}/#{found_index.id_index}_headers"].first?
        if (header_file && body_file)
          Replay::Log.debug { "Found header_file path: #{header_file}" }
          Replay::Log.debug { "Found body_file path: #{body_file}" }
          case maybe_records = @config.records
          when Records
            maybe_records.from(File.open(header_file), File.open(body_file))
          else
            Replay::Log.debug { "Failed to parse header or body from file." }
            nil
          end
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
