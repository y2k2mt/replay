require "./app"

server_port = 8899_i16
mode = Config::Mode::Replay
base_url : String? = nil
query_options : Array(String) = [] of String

parsed = OptionParser.parse do |parser|
  parser.banner = "Replay: Record and Preplay!"

  parser.on "-v", "--version", "Show version" do
    puts Replay::VERSION
    exit
  end

  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end

  parser.on "-p PORT", "--port PORT", "Server port" do |port|
    port.to_i16?.try do |port_number|
      server_port = port_number
    end
  end

  parser.on "-r URL", "--record URL", "Run as recording mode" do |url|
    mode = Config::Mode::Record
    base_url = url
  end

  parser.on "-R URL", "--replay URL", "Run as replaying mode" do |url|
    mode = Config::Mode::Replay
    base_url = url
  end

  parser.on "-f URL", "--find URL", "Find resources" do |options|
    query_options = ARGV[1..]
    base_url = query_options[0]
    mode = Config::Mode::Replay
  end

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

if !base_url
  STDERR.puts "ERROR: Option '-r' or '-R' is required."
  STDERR.puts parsed
  exit(1)
end

base_url.try do |url|
  if (query_options.empty?)
    start_server(Config.new(url, server_port, mode))
  else
    STDERR.puts find_from_filesystem(Config.new(url, server_port, mode), query_options)
  end
end
