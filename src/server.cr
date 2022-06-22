class Server
  def initialize(@config : ServerConfig)
    @server = HTTP::Server.new(handlers(config))
  end

  def handlers(config : ServerConfig) : Array(HTTP::Handler)
    handlers = [] of HTTP::Handler
    case config.mode
    when ServerConfig::Mode::Replay
      handlers << Parrot::RepeatingHandler.new
    when ServerConfig::Mode::Record
      handlers << Parrot::RecordingHandler.new
    end
    handlers
  end

  def start : Void
    address = @server.bind_tcp 8080
    Parrot::Log.info { "Listening on http://#{address}" }
    Parrot::Log.info { "Running as #{@config.mode}ing mode for #{@config.base_url}" }
    @server.listen
  end

  def stop : Void
    @server.close
  end
end
