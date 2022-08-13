class HTTPIndexes
  include Indexes

  def initialize(@config : Config)
  end

  def from(io : IO) : RequestError | Index
    http_request = HTTP::Request.from_io(io)
    HTTPRequest.new(http_request, conig)
  end
end

class HTTPIndex
  include Indexes

  def initialize(http_request, config)
    @id = Random::Secure.hex
    @host_name = config.base_uri_host
    @path = http_request.path
    @method = http_request.method
    @headers = http_request.headers.to_h
    @body = http_request.body.try &.gets_to_end || ""
    @params = http_request.query_params.to_h
  end

  def base_index : String
    Digest::SHA256.hexdigest do |ctx|
      ctx << self.host_name << self.path << self.method
    end
  end

  def ==(other : Request) : Bool
    Replay::Log.debug { "Comparing : #{self.base_index} and #{index.base_index}." }
    index.base_index == self.base_index &&
      (self.headers.empty? || self.headers.find { |k, v| !index.headers[k] || index.headers[k] != v } == nil) &&
      (self.params.empty? || self.params.find { |k, v| !index.params[k] || index.params[k] != v } == nil) &&
      (self.body.empty? || self.body == index.body)
  end
end

module Record
  def response(io : IO)
  end
end

module Datastore
  def persist(index : Index, record : Record) : Void
  end

  def find(index : Index) : Record?
  end
end

class RecordsImpl
  include Records

  def initialize(@datastore : Datastore)
  end

  def proxy(index : Index)
    ProxyError | Record
  end
end
