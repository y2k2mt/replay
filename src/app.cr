require "./shards"
require "./logger"
require "./config"
require "./record"
require "./index"
require "./recorder"
require "./handler"
require "./server"

def start_server(config : Config)
  server = Server.new(config)

  Signal::INT.trap do
    Replay::Log.info { "Stopping Replay server." }
    server.stop
    Replay::Log.info { "Replay server stopped." }
  end

  server.start
end
