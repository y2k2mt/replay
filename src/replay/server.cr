class Server
  def initialize(@config : Config)
    @server = HTTP::Server.new(handlers(config))
  end

  def handlers(config : Config) : Array(HTTP::Handler)
    handlers = [] of HTTP::Handler
    case config.mode
    when Config::Mode::Replay
      handlers << Replay::RepeatingHandler.new(config)
    when Config::Mode::Record
      handlers << Replay::RecordingHandler.new(config)
    end
    handlers
  end

  def start : Void
    address = @server.bind_tcp @config.port
    Replay::Log.info { "Listening on http://#{address}" }
    Replay::Log.info { "Running as #{@config.mode}ing mode for #{@config.base_uri}" }
    @server.listen
  end

  def stop : Void
    @server.close
  end
end
