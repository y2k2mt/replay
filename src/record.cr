struct Record
  getter uri, method, headers, body

  @uri : URI
  @method : String
  @headers : HTTP::Headers
  @body : IO

  def initialize(base_uri, request, client_response)
    base_uri.path = request.path
    @uri = base_uri
    @method = request.method
    @headers = request.headers
    @body = client_response.body_io
  end
end
