class IncomingHTTPRequest
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
    maybe_host = base_uri.host
    if maybe_host
      http_request.headers["Host"] = maybe_host
      @host_name = maybe_host
    else
      raise "Request URI is collapsed : #{base_uri}"
    end
    @id = Random::Secure.hex
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

  getter(base_index : String) {
    Digest::SHA256.hexdigest do |ctx|
      ctx << @host_name << @path << @method
    end
  }

  getter(id_index : String) {
    "#{base_index}_#{@id}"
  }

  def proxy
    ProxyError | Record
    @http_request.headers["Host"] = @host_name
    client_response = HTTP::Client.new(@base_uri).exec(@http_request)
    HTTPRecord.new(client_response, self) || ProxyError.new
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

  def match_query(query : Array(String)) : Request?
    # FIXME:implicit dependency
    method_query = query[1]?.try { |q| self.method == q }
    path_query = query[2]?.try { |q| self.path.includes?(q) }
    if (self.host_name == (query[0]?.try { |q| URI.parse(q).hostname } || "") &&
       (method_query == nil || method_query) &&
       (path_query == nil || path_query))
      self
    else
      nil
    end
  end
end

class RecordedHTTPRequest
  include Request

  getter host_name, path, method, body, params, headers

  @id : String
  @host_name : String
  @method : String
  @path : String
  @headers : Hash(String, Array(String))
  @body : String
  @params : Hash(String, String)
  @base_uri : URI

  def initialize(@base_uri : URI?, request_json : JSON::Any)
    @id = request_json["id"].to_s
    @path = request_json["path"].to_s
    @method = request_json["method"].to_s
    @headers = request_json["indexed"]["headers"].as_h.reduce({} of String => Array(String)) do |acc, (k, v)|
      acc[k] = v.as_a.map(&.to_s)
      acc
    end
    maybe_host = @base_uri.host
    if maybe_host
      @host_name = maybe_host
    else
      raise "Request URI is collapsed : #{base_uri}"
    end
    body_condition = request_json["indexed"]["body"]
    @body = body_condition.as_h?.try{ |b| b.to_json } || body_condition.as_s
    @params = request_json["indexed"]["params"].as_h.reduce({} of String => String) do |acc, (k, v)|
      acc[k] = v.as_s
      acc
    end
  end

  getter(base_index : String) {
    Digest::SHA256.hexdigest do |ctx|
      ctx << @host_name << @path << @method
    end
  }

  getter(id_index : String) {
    "#{base_index}_#{@id}"
  }

  def score(other : Request) : Int32
    Replay::Log.debug { "Comparing : #{self.base_index} and #{other.base_index}." }
    case other
    when IncomingHTTPRequest
      if (other.base_index != self.base_index || !match_headers(self, other))
        -1
      else
        # TODO: Plaggable comparators
        if self.body.empty?
          0
        elsif self.body == other.body
          1024
        else
          match_json(self, other) + match_form(self, other)
        end
      end
    else
      -1
    end
  end

  private def match_headers(i, other)
    (i.headers.empty? || i.headers.find { |k, v| !other.headers[k] || other.headers[k] != v } == nil) &&
      (i.params.empty? || i.params.find { |k, v| !other.params[k] || other.params[k] != v } == nil)
  end

  private def match_json(i : Request, other : Request) : Int32
    me = JSON.parse i.body
    another = JSON.parse other.body
    match_json_internal me, another
  rescue e : JSON::ParseException
    0
  end

  private def match_json_internal(me : JSON::Any, other : JSON::Any) : Int32
    me.as_h.keys.reduce(0) do |acc, key|
      case value = other[key]
      when .as_s?
        value == me[key].as_s? ? acc + 1 : return -1
      when .as_i?
        value == me[key].as_i? ? acc + 1 : return -1
      when .as_bool?
        value == me[key].as_bool? ? acc + 1 : return -1
      when .as_a?
        value == me[key].as_a? ? acc + 1 : return -1
      when .as_f?
        value == me[key].as_f? ? acc + 1 : return -1
      when .as_h?
        me[key].as_h?.try do |_|
          child = match_json_internal me[key], value
          child == -1 ? return -1 : child + acc
        end || acc
      else
        acc
      end
    end || 0
  end

  private def match_form(i : Request, other : Request) : Int32
    me = split_form(i.body)
    another = split_form(other.body)
    begin
      me.keys.reduce(0) do |acc, key|
        if me[key] == another[key]
          acc + 1
        else
          return -1
        end
      end
    rescue e : KeyError
      0
    end
  end

  private def split_form(body)
    body.split("&").map do |and|
      v = and.split("=")
      {v[0], v[1]?}
    end.to_h
  end

  def match_query(query : Array(String)) : Request?
    # FIXME:implicit dependency
    method_query = query[1]?.try { |q| self.method == q }
    path_query = query[2]?.try { |q| self.path.includes?(q) }
    if (self.host_name == (query[0]?.try { |q| URI.parse(q).hostname } || "") &&
       (method_query == nil || method_query) &&
       (path_query == nil || path_query))
      self
    else
      nil
    end
  end
end
