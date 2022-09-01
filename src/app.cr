require "./shards"
require "./replay/*"
require "./replay/http/*"
require "./replay/datasource/*"

def start_server(config : Config)
  server = Server.new(config)

  Signal::INT.trap do
    Replay::Log.info { "Stopping Replay server." }
    server.stop
    Replay::Log.info { "Replay server stopped." }
  end

  server.start
end
