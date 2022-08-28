require "./shards"
require "./replay/logger"
require "./replay2/config"
require "./replay2/models"
require "./replay2/impls"
require "./replay2/datasource/*"
require "./replay2/errors"
require "./replay2/server"

# require "./replay/record"
# require "./replay/index"
# require "./replay/recorder"
# require "./replay/handler"
# require "./replay/server"

def start_server(config : Config)
  server = Server.new(config)

  Signal::INT.trap do
    Replay::Log.info { "Stopping Replay server." }
    server.stop
    Replay::Log.info { "Replay server stopped." }
  end

  server.start
end
