class HTTPRecord
  include Record

  def initialize(@client_response : HTTP::Client::Response)
    @headers = @client_response.headers
    @body = @client_response.body
    @response_status = @client_response.status_code
  end

  def initialize(headers_content : IO, body_content : IO)
    header = JSON.parse(headers_content.gets_to_end)
    response_headers = HTTP::Headers.new
    header["headers"].as_h.map do |k, v|
      if k != "status"
        response_headers[k] = v.as_s
      end
    end
    @headers = response_headers
    Replay::Log.debug { "Recorded response headers: #{response_headers}" }
    @body = body_content.gets_to_end
    @response_status = header["status"].as_i
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
