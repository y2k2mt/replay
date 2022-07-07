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
    header_digest = Digest::SHA256.hexdigest do |ctx|
      ctx << @path << @method
      @indexed_header_names.each do |name|
        ctx << @headers[name]
      end
    end
    # TODO: Add param_digest
    header_digest
  end

  def index_conditions
    candidates = @headers.to_h.partition { |k, _| @indexed_header_names.includes?(k) }
    {
      "indexed"     => candidates[0].to_h.merge({"path" => @path, "method" => @method}),
      "not_indexed" => candidates[1].to_h,
    }
  end
end
