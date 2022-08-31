class HTTPRecord
  include Record

  def initialize(@client_response : HTTP::Client::Response)
    @headers = @client_response.headers
    @body = @client_response.body
    @response_status = @client_response.status_code
  end

  def initialize(headers : JSON::Any,body_content : IO)
    @headers = @client_response.headers
    @body = @client_response.body
    @response_status = @client_response.status_code
  end

  def response(io : IO)
    @client_response.to_io(io)
  end

  def metadatas : JSON::Any
    JSON.parse(JSON.build do |json|
      json.object do
        json.field "headers", @headers
        json.field "status", @response_status
      end
    end)
  end

  def entity : String
    @body
  end
end
