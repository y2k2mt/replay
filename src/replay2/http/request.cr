class HTTPRequest
  include Request

  getter host_name, path, method, body, params

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
      ctx << @host_name << @path << @method
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

  def metadatas : JSON::Any
    JSON.parse(JSON.build do |json|
      json.object do
        json.field "id", @id
        json.field "host", @host_name
        json.field "method", @method
        json.field "path", @path
        json.field "indexed" do
          json.field "headers", {} of String => Array(String)
          json.field "params", {} of String => String
          json.field "body", ""
        end
        json.field "not_indexed" do
          json.field "headers", @headers
          json.field "params", @params
          json.field "body", @body
        end
      end
    end)
  end
end
