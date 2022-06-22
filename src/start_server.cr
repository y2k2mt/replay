require "./app"

def start_server
  server = Server.new

  Signal::INT.trap do
    server.stop
  end

  server.start
end
