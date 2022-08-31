class HTTPRecord
  include Record

  def initialize(@client_response : HTTP::Client::Response)
    @headers = @client_response.headers
    @body = @client_response.body
    @response_status = @client_response.status_code
  end

  def initialize(headers_content : IO, body_content : IO)
    header_hash = Hash(String, Array(String)).from_json(headers_content.gets_to_end)
    response_headers = HTTP::Headers.new
    header_hash.map do |k, v|
      if k != "response_status"
        response_headers[k] = v
      end
    end
    @headers = response_headers
    @body = body_content.gets_to_end
    @response_status = header_hash["response_status"].to_i32
    @client_response = HTTP::Client::Response.new(@response_status, @body, @headers)
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
