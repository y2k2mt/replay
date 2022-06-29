class ServerConfig
  enum Mode
    Record
    Replay
  end

  getter port, mode

  getter(base_uri : URI) {
    @base_url.try do |url|
      URI.parse(url)
    end || raise "Invalid configuration [base_url] : #{@base_url}"
  }

  getter(base_uri_host : String) {
    base_uri.host.try do |host|
      host
    end || raise "Invalid configuration [base_url] : #{@base_url}"
  }

  def initialize(@base_url : String, @port : Int16, @mode : Mode)
  end
end
