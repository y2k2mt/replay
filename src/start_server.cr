require "./app"

def start_server(config : ServerConfig)
  server = Server.new(config)

  Signal::INT.trap do
    server.stop
  end

  server.start
end
