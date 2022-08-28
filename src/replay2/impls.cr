class HTTPRequests
  include Requests

  def initialize(@config : Config)
  end

  def from(io : IO) : RequestError | Request
    maybe_http_request = HTTP::Request.from_io(io)
    case maybe_http_request
    when HTTP::Request
      HTTPRequest.new(maybe_http_request, @config)
    else
      RequestError.new
    end
  end
end

class HTTPRequest
  include Request

  getter host_name,path,method

  @id : String
  @host_name : String
  @method : String
  @path : String
  @headers : Hash(String, Array(String))
  @body : String
  @params : Hash(String, String)

  def initialize(@http_request : HTTP::Request, @config : Config)
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

  def proxy
    ProxyError | Record
    @http_request.headers["Host"] = @host_name
    client_response = HTTP::Client.new(@config.base_uri).exec(@http_request)
    HTTPRecord.new(client_response) || ProxyError.new
  end
end

class HTTPRecord
  include Record

  def initialize(@client_response : HTTP::Client::Response)
    @headers = @client_response.headers
    @body = @client_response.body
    @response_status = @client_response.status_code
  end

  def response(io : IO)
    @client_response.to_io(io)
  end
end

module Recorder
  def self.record(io : IO, requests : Requests, datasource : Datasource) : RequestError | ProxyError | Record
    case maybe_request = requests.from(io)
    when RequestError
      maybe_request
    when Request
      case maybe_record = maybe_request.proxy
      when Record
        datasource.persist(maybe_request,maybe_record)
      when ProxyError
        maybe_record
      end
    else
      ProxyError.new
    end
  end
end
