struct Index
  @host_name : String
  @method : String
  @path : String
  @headers : Hash(String, Array(String))
  @id : String
  @indexed_header_names : Array(String)

  def initialize(config, request)
    @host_name = config.base_uri_host
    @path = request.path
    @method = request.method
    @headers = request.headers.to_h
    @id = Random::Secure.hex
    @indexed_header_names = [] of String
  end

  private def initialize(
    @host_name,
    @path,
    @method,
    @headers,
    @id,
    @indexed_header_names = [] of String
  )
  end

  def self.from(index_content : String)
    index = JSON.parse(index_content)
    new(
      host_name = index["host"].to_s,
      path = index["path"].to_s,
      method = index["method"].to_s,
      headers = index["indexed"].as_h.reduce({} of String => Array(String)) { |acc, (k, v)|
        acc[k] = v.as_a.map(&.to_s)
        acc
      },
      id = index["id"].to_s
    )
  end

  getter(meta_index : String) {
    Digest::SHA256.hexdigest do |ctx|
      ctx << @host_name << @path << @method
    end
  }

  getter(id_index : String) {
    "#{meta_index}_#{@id}"
  }

  def match?(index : Index) : Bool
    index.meta_index == self.meta_index
  end

  def conditions
    {
      "id"          => @id,
      "host"        => @host_name,
      "method"      => @method,
      "path"        => @path,
      "indexed"     => {} of String => Array(String),
      "not_indexed" => @headers.to_h,
    }
  end
end
