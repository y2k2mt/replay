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
    FileSystemDatasource.new(self.base_dir_path, self.records)
  }

  getter(requests : Requests) {
    case scheme = base_uri.scheme
    when "http"
      HTTPRequests.new(self.base_uri)
    when "https"
      HTTPRequests.new(self.base_uri)
    else
      raise UnsupportedProtocolError.new(scheme)
    end
  }

  getter(records : Records) {
    case scheme = base_uri.scheme
    when "http"
      HTTPRecords.new
    when "https"
      HTTPRecords.new
    else
      raise UnsupportedProtocolError.new(scheme)
    end
  }

  getter(error_handler : ErrorHandler) {
    case scheme = base_uri.scheme
    when "http"
      HTTPErrorHandler.new(self.mode)
    when "https"
      HTTPErrorHandler.new(self.mode)
    else
      raise UnsupportedProtocolError.new(scheme)
    end
  }

  def initialize(@base_url : String, @port : Int16, @mode : Mode, @base_dir_path = "#{Path.home}/.replay-recorder")
  end

  def self.empty
    Config.new("", 0, Mode::Replay)
  end
end
