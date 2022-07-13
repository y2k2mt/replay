require "./app"

def start_server(config : Config)
  server = Server.new(config)

  Signal::INT.trap do
    Parrot::Log.info { "Stopping parrot server." }
    server.stop
    Parrot::Log.info { "Parrot server stopped." }
  end

  server.start
end
