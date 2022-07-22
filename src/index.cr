struct Index
  @host_name : String
  @method : String
  @path : String
  @headers : HTTP::Headers
  @indexed_header_names : Array(String)

  def initialize(config, request)
    @host_name = config.base_uri_host
    @path = request.path
    @method = request.method
    @headers = request.headers
    @indexed_header_names = [] of String
  end

  def index
    meta_digest = Digest::SHA256.hexdigest do |ctx|
      ctx << @host_name << @path << @method
    end
    header_digest = Digest::SHA256.hexdigest do |ctx|
      index_conditions_hash = index_conditions["indexed"]
      index_conditions_hash.keys.sort.each do |k|
        case v = index_conditions_hash[k]
        when String
          ctx << v
        when Array(String)
          v.each do |x|
            ctx << x
          end
        end
      end
    end
    # TODO: Add param_digest
    # "#{meta_digest}_#{header_digest}_#{param_digest}"
    "#{meta_digest}_#{header_digest}"
  end

  def index_conditions
    candidates = @headers.to_h.partition { |k, _| @indexed_header_names.includes?(k) }
    {
      "indexed"     => candidates[0].to_h.merge({"path" => @path, "method" => @method}),
      "not_indexed" => candidates[1].to_h,
    }
  end
end
