require "./start_server"

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
  parser.on "-r=URL", "--record=URL", "Run as recording mode" do |url|
    start_server
    exit
  end
end
