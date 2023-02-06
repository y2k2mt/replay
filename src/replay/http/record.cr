class HTTPRecord
  include Record

  def initialize(
    @headers : HTTP::Headers,
    @body : String,
    @response_status : Int32,
    @response : HTTP::Client::Response,
    @request : Request
  )
  end

  def initialize(client_response : HTTP::Client::Response, request : Request)
    initialize(
      headers: client_response.headers,
      body: client_response.body,
      response_status: client_response.status_code,
      response: client_response,
      request: request,
    )
  end

  def initialize(headers_content : IO, body_content : IO, request : Request)
    header = JSON.parse(headers_content.gets_to_end)
    response_headers = HTTP::Headers.new
    header["headers"].as_h.reject do |k, _|
      k == "status"
    end.map do |k, v|
      case v
      when .as_s?
        response_headers[k] = v.as_s
      when .as_a?
        response_headers[k] = v.as_a.join(";")
      else
        # Do nothing
      end
    end
    Replay::Log.debug { "Recorded response headers: #{response_headers}" }
    body = body_content.gets_to_end
    response_status = header["status"].as_i
    initialize(
      headers: response_headers,
      body: body,
      response_status: response_status,
      response: HTTP::Client::Response.new(response_status, body, response_headers),
      request: request,
    )
  end

  def response(io : IO)
    @headers["Transfer-Encoding"]?.try do |encoding|
      if encoding == "chunked"
        # Chunked transfer encoding not supported.
        @headers.delete("Transfer-Encoding")
      end
      HTTP::Client::Response.new(@response_status, @body, @headers).to_io(io)
    end || (@response.to_io(io))
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

  def request : Request
    @request
  end

  def match_query(query : Array(String)) : Record?
    @request.match_query(query).try do |_|
      self
    end
  end
end
