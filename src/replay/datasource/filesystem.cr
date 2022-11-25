class FileSystemDatasource
  include Datasource

  def initialize(base_dir_path : String, @records : Records, @requests : Requests)
    @index_file_dir = "#{base_dir_path}/indexes"
    @reply_file_dir = "#{base_dir_path}/replies"
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

  def get(request : Request) : Record | NoIndexFound | CorruptedReplayResource | NoResourceFound
    meta_index = request.base_index
    index_files = Dir["#{@index_file_dir}/**/#{meta_index}_*"]
    if index_files.empty?
      Replay::Log.debug { "No index_file avairable." }
      NoIndexFound.new(meta_index)
    else
      found_index_file = index_files.find do |index_file|
        candidate = @requests.from(JSON.parse(File.read(index_file)))
        candidate == request
      end
      found_index_file.try do |found|
        Replay::Log.debug { "Found index_file path: #{found}" }
        found_index = @requests.from(JSON.parse(File.read(found)))
        body_file = Dir["#{@reply_file_dir}/#{found_index.id_index}"].first?
        header_file = Dir["#{@reply_file_dir}/#{found_index.id_index}_headers"].first?
        if (header_file && body_file)
          Replay::Log.debug { "Found header_file path: #{header_file}" }
          Replay::Log.debug { "Found body_file path: #{body_file}" }
          @records.from(File.open(header_file), File.open(body_file), found_index)
        else
          Replay::Log.debug { "No header_file and body_file avairable." }
          NoResourceFound.new(meta_index)
        end
      end || (
        Replay::Log.debug { "index_file not matched any." }
        NoIndexFound.new(meta_index)
      )
    end
  rescue e
    CorruptedReplayResource.new(e.message || "Found resource is broken!")
  end

  private def load(found : String) : Record | NoIndexFound | CorruptedReplayResource | NoResourceFound
    found_index = @requests.from(JSON.parse(File.read(found)))
    body_file = Dir["#{@reply_file_dir}/#{found_index.id_index}"].first?
    header_file = Dir["#{@reply_file_dir}/#{found_index.id_index}_headers"].first?
    if (header_file && body_file)
      Replay::Log.debug { "Found header_file path: #{header_file}" }
      Replay::Log.debug { "Found body_file path: #{body_file}" }
      @records.from(File.open(header_file), File.open(body_file), found_index)
    else
      Replay::Log.debug { "No header_file and body_file avairable." }
      NoResourceFound.new(found_index.id_index)
    end
  end

  def find(query : Array(String))
    (Dir["#{@index_file_dir}/*"].flat_map do |index_file_path|
      case record = load(index_file_path)
      when Record
        record.match_query(query).try do |_|
          index_file_path
        end
      else
        nil
      end
    end).reject(Nil)
  end
end
