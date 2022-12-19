class HTTPRequests
  include Requests

  def initialize(@base_uri : URI)
  end

  def from(io : IO) : RequestError | Request
    maybe_http_request = HTTP::Request.from_io(io)
    case maybe_http_request
    when HTTP::Request
      IncomingHTTPRequest.new(maybe_http_request, @base_uri)
    else
      RequestError.new "Failed to parse HTTP request"
    end
  end

  def from(request_json : JSON::Any) : Request
    Replay::Log.debug { "Loading index content : #{request_json}." }
    RecordedHTTPRequest.new(@base_uri, request_json)
  end
end
