require "./app"

server = Server.new

Signal::INT.trap do
  server.stop
end

server.start
