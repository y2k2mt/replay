struct Record
  getter uri, method, headers, body

  @headers : HTTP::Headers
  @body : String

  def initialize(client_response)
    @headers = client_response.headers
    @body = client_response.body
  end

end
