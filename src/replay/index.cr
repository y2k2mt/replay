struct Index
  getter id, host_name, method, path, headers, params
  @id : String
  @host_name : String
  @method : String
  @path : String
  @headers : Hash(String, Array(String))
  @params : Hash(String, String)

  def initialize(config, request)
    @id = Random::Secure.hex
    @host_name = config.base_uri_host
    @path = request.path
    @method = request.method
    @headers = request.headers.to_h
    @params = request.query_params.to_h
  end

  private def initialize(
    @id,
    @host_name,
    @path,
    @method,
    @headers,
    @params
  )
  end

  def self.from(index_content : String)
    Replay::Log.debug { "Loading index content : #{index_content}." }
    index = JSON.parse(index_content)
    new(
      id = index["id"].to_s,
      host_name = index["host"].to_s,
      path = index["path"].to_s,
      method = index["method"].to_s,
      headers = index["indexed"]["headers"].as_h.reduce({} of String => Array(String)) { |acc, (k, v)|
        acc[k] = v.as_a.map(&.to_s)
        acc
      },
      params = index["indexed"]["params"].as_h.reduce({} of String => String) { |acc, (k, v)|
        acc[k] = v.as_s
        acc
      },
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
    Replay::Log.debug { "Comparing : #{self.meta_index} and #{index.meta_index}." }
    index.meta_index == @meta_index &&
      (@headers.empty? || @headers.find { |k, v| !index.headers[k] || index.headers[k] != v } == nil) &&
      (@params.empty? || @params.find { |k, v| !index.params[k] || index.params[k] != v } == nil)
  end

  def conditions
    {
      "id"      => @id,
      "host"    => @host_name,
      "method"  => @method,
      "path"    => @path,
      "indexed" => {
        "headers" => {} of String => Array(String),
        "params"  => {} of String => String,
      },
      "not_indexed" => {
        "headers" => @headers,
        "params"  => @params,
      },
    }
  end
end
