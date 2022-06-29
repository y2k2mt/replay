class Server
  def initialize(@config : Config)
    @server = HTTP::Server.new(handlers(config))
  end

  def handlers(config : Config) : Array(HTTP::Handler)
    handlers = [] of HTTP::Handler
    case config.mode
    when Config::Mode::Replay
      handlers << Parrot::RepeatingHandler.new(config)
    when Config::Mode::Record
      handlers << Parrot::RecordingHandler.new(config)
    end
    handlers
  end

  def start : Void
    address = @server.bind_tcp 8080
    Parrot::Log.info { "Listening on http://#{address}" }
    Parrot::Log.info { "Running as #{@config.mode}ing mode for #{@config.base_uri}" }
    @server.listen
  end

  def stop : Void
    @server.close
  end
end
