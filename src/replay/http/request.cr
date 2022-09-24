class HTTPRequest
  include Request

  getter host_name, path, method, body, params, headers

  @id : String
  @host_name : String
  @method : String
  @path : String
  @headers : Hash(String, Array(String))
  @body : String
  @params : Hash(String, String)

  def initialize(@http_request : HTTP::Request, @base_uri : URI)
    base_uri.host.try do |host|
      http_request.headers["Host"] = host
    end
    @id = Random::Secure.hex
    @host_name = base_uri.host.not_nil!
    @path = @http_request.path
    @method = @http_request.method
    @headers = @http_request.headers.to_h
    if body = @http_request.body
      body_io = IO::Memory.new
      IO.copy(body, body_io, limit: 1_048_576)
      body_io.rewind
      @http_request.body = body_io
    end
    @body = http_request.body.try &.gets_to_end || ""
    if body_io
      body_io.rewind
      @http_request.body = body_io
    end
    @params = http_request.query_params.to_h
  end

  def initialize(
    id,
    base_uri,
    path,
    method,
    headers,
    body,
    params
  )
    @id = id
    @base_uri = base_uri
    @host_name = base_uri.host.not_nil!
    @path = path
    @method = method
    @headers = headers
    @body = body
    @params = params
    @http_request = HTTP::Request.new("", "")
  end

  getter(base_index : String) {
    Digest::SHA256.hexdigest do |ctx|
      ctx << @host_name << @path << @method
    end
  }

  getter(id_index : String) {
    "#{base_index}_#{@id}"
  }

  def ==(other : Request) : Bool
    Replay::Log.debug { "Comparing : #{self.base_index} and #{other.base_index}." }
    case other
    when HTTPRequest
      # TODO: Plaggable comparators
      other.base_index == self.base_index &&
        match_headers(self, other) &&
        (self.body.empty? || self.body == other.body || match_json(self, other) || match_form(self, other))
    else
      false
    end
  end

  private def match_headers(other)
    (self.headers.empty? || self.headers.find { |k, v| !other.headers[k] || other.headers[k] != v } == nil) &&
      (self.params.empty? || self.params.find { |k, v| !other.params[k] || other.params[k] != v } == nil)
  end

  private def match_json(i : Request, other : Request) : Bool
    me = JSON.parse i.body
    another = JSON.parse other.body
    match_json_internal me, another
  rescue
    false
  end

  private def match_json_internal(me : JSON::Any, other : JSON::Any) : Bool
    me.as_h.keys.find do |key|
      case value = other[key]
      when .as_s?
        puts value
        value != me[key].as_s?
      when .as_i?
        value != me[key].as_i?
      when .as_bool?
        value != me[key].as_bool?
      when .as_a?
        value != me[key].as_a?
      when .as_f?
        value != me[key].as_f?
      when .as_h?
        me[key].as_h?.try do |_|
          match_json_internal me[key], value
        end ? nil : value
      end
    end == nil
  end

  private def match_form(i : Request, other : Request) : Bool
    me = i.body.split("&").map(&.split("=").tap { |v| {v[0]? => v[1]?} }).to_h
    another = other.body.split("&").map(&.split("=").tap { |v| {v[0]? => v[1]?} }).to_h
    me.find { |k, v| another[k] != v } == nil
  end

  def proxy
    ProxyError | Record
    @http_request.headers["Host"] = @host_name
    client_response = HTTP::Client.new(@base_uri).exec(@http_request)
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
          json.object do
            json.field "headers", {} of String => Array(String)
            json.field "params", {} of String => String
            json.field "body", ""
          end
        end
        json.field "not_indexed" do
          json.object do
            json.field "headers", @headers
            json.field "params", @params
            json.field "body", @body
          end
        end
      end
    end)
  end
end
