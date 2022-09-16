class HTTPRequests
  include Requests

  def initialize(@base_uri : URI)
  end

  def from(io : IO) : RequestError | Request
    maybe_http_request = HTTP::Request.from_io(io)
    case maybe_http_request
    when HTTP::Request
      HTTPRequest.new(maybe_http_request, @base_uri)
    else
      RequestError.new
    end
  end

  def from(request_json : JSON::Any) : Request
    Replay::Log.debug { "Loading index content : #{request_json}." }
    HTTPRequest.new(
      request_json["id"].to_s,
      @base_uri,
      request_json["path"].to_s,
      request_json["method"].to_s,
      request_json["indexed"]["headers"].as_h.reduce({} of String => Array(String)) { |acc, (k, v)|
        acc[k] = v.as_a.map(&.to_s)
        acc
      },
      request_json["indexed"]["body"].as_s,
      request_json["indexed"]["params"].as_h.reduce({} of String => String) { |acc, (k, v)|
        acc[k] = v.as_s
        acc
      },
    )
  end
end
