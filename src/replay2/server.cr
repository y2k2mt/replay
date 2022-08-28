class Server
  def initialize(@config : Config)
    @server = TCPServer.new("0.0.0.0", @config.port)
  end

  def start : Void
    Replay::Log.info { "Listening on 0.0.0.0:#{@config.port}" }
    Replay::Log.info { "Running as #{@config.mode}ing mode for #{@config.base_uri}" }
    while client = @server.accept?
      spawn handle_client(client)
    end
  end

  def handle_client(io)
    case maybe_requests = @config.requests
    when Requests
      case maybe_record = Recorder.record(io, maybe_requests)
      when Record
        maybe_record.response(io)
      else
        pp maybe_record
        # TODO: response err
      end
    when UnsupportedProtocolError
      # TODO: response err
      pp maybe_requests
    end
  end

  def stop : Void
    @server.close
  end
end
