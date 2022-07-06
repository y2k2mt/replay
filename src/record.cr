struct Record
  getter uri, method, headers, body

  @uri : URI
  @method : String
  @headers : HTTP::Headers
  @body : String

  def initialize(base_uri, request, client_response)
    base_uri.path = request.path
    @uri = base_uri
    @method = request.method
    @headers = client_response.headers
    @body = client_response.body
  end

  def index
    Digest::SHA256.hexdigest do |ctx|
      ctx << uri.path << @method
    end
  end

  def index_conditions
    headers.to_h
  end
end
