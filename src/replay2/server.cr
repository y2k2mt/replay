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
        # TODO: response err
        Replay::Log.error { "Invalid request: #{maybe_record}" }
      when ProxyError
        # TODO: response err
        Replay::Log.error { "Error caused when proxing request: #{maybe_record}" }
      end
    when UnsupportedProtocolError
      # TODO: response err
      Replay::Log.error { "Unsupported protocol: #{maybe_requests.protocol}" }
    end
  end

  def handle_replay(io)
  end

  def stop : Void
    @server.close
  end
end
