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
    case maybe_record = Recorder.record(io, @config.requests, @config.datasource)
    when Record
      maybe_record.response(io)
    when RequestError
      Replay::Log.error { "Invalid request: #{maybe_record}" }
      @config.error_handler.response_error(io, maybe_record)
    when ProxyError
      Replay::Log.error { "Error caused when proxing request: #{maybe_record}" }
      @config.error_handler.response_error(io, maybe_record)
    end
  end

  def handle_replay(io)
    case maybe_request = @config.requests.from(io)
    when Request
      Replay::Log.debug { "Repeater: request index : #{maybe_request.base_index}" }
      case record = @config.datasource.get(maybe_request)
      when Record
        record.response(io)
      else
        @config.error_handler.response_error(io, record)
      end
    when RequestError
      Replay::Log.error { "Error caused when replaying request: #{maybe_request}" }
      @config.error_handler.response_error(io, maybe_request)
    end
  end

  def stop : Void
    @server.close
  end
end
