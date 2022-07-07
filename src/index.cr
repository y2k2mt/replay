struct Index
  @method : String
  @path : String
  @headers : HTTP::Headers

  def initialize(request)
    @path = request.path
    @method = request.method
    @headers = request.headers
  end

  def index
    header_digest = Digest::SHA256.hexdigest do |ctx|
      ctx << @path << @method << @headers["Host"]
    end
    #TODO: Add param_digest
    header_digest
  end

  def index_conditions
    candidates = @headers.to_h.partition { |k,_| k == "Host" }
    {
      "indexed" => candidates[0].to_h.merge({"path" => @path, "method" => @method}),
      "not_indexed" => candidates[1].to_h
    }
  end
end
