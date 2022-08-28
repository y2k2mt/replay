require "./shards"
require "./replay2/*"
require "./replay2/http/*"
require "./replay2/datasource/*"

def start_server(config : Config)
  server = Server.new(config)

  Signal::INT.trap do
    Replay::Log.info { "Stopping Replay server." }
    server.stop
    Replay::Log.info { "Replay server stopped." }
  end

  server.start
end
