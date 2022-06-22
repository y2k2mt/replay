require "./start_server"

server_port = 8080_i16
mode = ServerConfig::Mode::Replay
base_url : String? = nil

OptionParser.parse do |parser|
  parser.banner = "Parrot: Record and Preplay!"

  parser.on "-v", "--version", "Show version" do
    puts Parrot::VERSION
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end

  parser.on "-p=PORT", "--port=PORT", "Server port" do |port|
    server_port = port
  end
  parser.on "-r URL", "--record=URL", "Run as recording mode" do |url|
    mode = ServerConfig::Mode::Record
    base_url = url
  end
  parser.on "-R URL", "--replay=URL", "Run as replaying mode" do |url|
    mode = ServerConfig::Mode::Replay
    base_url = url
  end
end

base_url.try do |url|
  start_server(ServerConfig.new(url, server_port, mode))
end
