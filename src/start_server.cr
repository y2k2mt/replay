require "./app"

def start_server(config : Config)
  server = Server.new(config)

  Signal::INT.trap do
    server.stop
  end

  server.start
end
