struct Index
  @method : String
  @path : String
  @headers : HTTP::Headers
  @indexed_header_names : Array(String)

  def initialize(request)
    @path = request.path
    @method = request.method
    @headers = request.headers
    @indexed_header_names = ["Host"]
  end

  def index
    meta_digest = Digest::SHA256.hexdigest do |ctx|
      ctx << @path << @method
    end
    header_digest = Digest::SHA256.hexdigest do |ctx|
      index_conditions["indexed"].each do |_, v|
        case v
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
