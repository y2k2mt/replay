class Server
  def initialize(@config : Config)
    @server = TCPServer.new("0.0.0.0", @config.port)
  end

  def start : Void
    Replay::Log.info { "Listening on 0.0.0.0:#{@config.port}" }
    Replay::Log.info { "Running as #{@config.mode}ing mode for #{@config.base_uri}" }
    handler = (case @config.mode
    when Config::Mode::Record
      ->(client : IO) { handle_record(client) }
    when Config::Mode::Replay
      ->(client : IO) { handle_replay(client) }
    end)
    while client = @server.accept?
      spawn do
        handler.try do |h|
          h.call(client)
        end
      end
    end
  end

  def handle_record(io)
    case maybe_requests = @config.requests
    when Requests
      case maybe_record = Recorder.record(io, maybe_requests, @config.datasource)
      when Record
        maybe_record.response(io)
      when RequestError
        Replay::Log.error { "Invalid request: #{maybe_record}" }
        maybe_requests.response_error(io, maybe_record)
      when ProxyError
        Replay::Log.error { "Error caused when proxing request: #{maybe_record}" }
        maybe_requests.response_error(io, maybe_record)
      end
    when UnsupportedProtocolError
      Replay::Log.error { "Unsupported protocol: #{maybe_requests.protocol}" }
      raise Exception.new("Unsupported protocol")
    end
  end

  def handle_replay(io)
    case maybe_requests = @config.requests
    when Requests
      case maybe_request = maybe_requests.from(io)
      when Request
        Replay::Log.debug { "Repeater: request index : #{maybe_request.base_index}" }
        record = @config.datasource.find(maybe_request, maybe_requests)
        if record
          record.response(io)
        else
          maybe_requests.response_error(io)
        end
      when RequestError
        Replay::Log.error { "Error caused when replaying request: #{maybe_request}" }
        maybe_requests.response_error(io, maybe_request)
      end
    when UnsupportedProtocolError
      Replay::Log.error { "Unsupported protocol: #{maybe_requests.protocol}" }
      raise Exception.new("Unsupported protocol")
    end
  end

  def stop : Void
    @server.close
  end
end
