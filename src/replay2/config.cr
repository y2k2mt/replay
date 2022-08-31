class Config
  enum Mode
    Record
    Replay
  end

  getter port, mode, base_dir_path

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

  getter(datasource : Datasource) {
    FileSystemDatasource.new(self)
  }

  getter(requests : Requests | UnsupportedProtocolError) {
    case scheme = base_uri.scheme
    when "http"
      HTTPRequests.new(self)
    when "https"
      HTTPRequests.new(self)
    else
      UnsupportedProtocolError.new(scheme)
    end
  }

  def initialize(@base_url : String, @port : Int16, @mode : Mode, @base_dir_path = "#{Path.home}/.replay-recorder")
  end
end
