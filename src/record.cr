struct Record
  getter headers, body, response_status

  @headers : HTTP::Headers
  @body : String
  @response_status : Int32

  def initialize(client_response)
    @headers = client_response.headers
    @body = client_response.body
    @response_status = client_response.status_code
  end

  def initialize(@headers : HTTP::Headers, @body : String,@response_status : Int32)
  end
end
