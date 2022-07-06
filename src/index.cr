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
    Digest::SHA256.hexdigest do |ctx|
      ctx << @path << @method << @headers.to_json
    end
  end

  def index_conditions
    @headers.to_h.merge({"path" => @path, "method" => @method})
  end
end
