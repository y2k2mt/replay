class HTTPErrorHandler
  include ErrorHandler

  def initialize(@mode : Config::Mode)
  end

  def response_error(output : IO, error : Object? = nil) : Void
    response = HTTP::Server::Response.new(output)
    response.content_type = "text/plain"
    message = "Failed to #{@mode}"
    case error
    when RequestError
      response.status_code = 400
      message = "Failed to parse request"
    when ProxyError
      response.status_code = 503
      message = "Failed to process proxy request"
    when UnsupportedProtocolError
      response.status_code = 500
      message = "Unsupported protocol : #{error.protocol}"
    when NoIndexFound
      response.status_code = 404
      message = "Not recorded yet : No index found : #{error.index}"
    when NoResourceFound
      response.status_code = 404
      message = "Not recorded yet : No resource found : #{error.index}"
    when CorruptedReplayResource
      response.status_code = 500
      message = "Broken resource : #{error.index}"
    else
      response.status_code = 500
    end
    final_message = "[#{@mode}] #{message}"
    response.puts final_message
    response.content_length = final_message.size
    response.flush
  end
end
