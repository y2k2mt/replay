class HTTPRequests
  include Requests

  def initialize(@config : Config)
  end

  def from(io : IO) : RequestError | Request
    maybe_http_request = HTTP::Request.from_io(io)
    case maybe_http_request
    when HTTP::Request
      HTTPRequest.new(maybe_http_request, @config)
    else
      RequestError.new
    end
  end

  def from(request_json : JSON::Any)
    Replay::Log.debug { "Loading index content : #{request_json}." }
    HTTPRequest.new(
      id = request_json["id"].to_s,
      host_name = request_json["host"].to_s,
      path = request_json["path"].to_s,
      method = request_json["method"].to_s,
      headers = request_json["indexed"]["headers"].as_h.reduce({} of String => Array(String)) { |acc, (k, v)|
        acc[k] = v.as_a.map(&.to_s)
        acc
      },
      body = request_json["indexed"]["body"].as_s,
      params = request_json["indexed"]["params"].as_h.reduce({} of String => String) { |acc, (k, v)|
        acc[k] = v.as_s
        acc
      },
    )
  end
end
