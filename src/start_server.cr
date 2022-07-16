require "./app"

def start_server(config : Config)
  server = Server.new(config)

  Signal::INT.trap do
    Replay::Log.info { "Stopping parrot server." }
    server.stop
    Replay::Log.info { "Replay server stopped." }
  end

  server.start
end
