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
    maybe_host = base_uri.host
    if maybe_host
      @host_name = maybe_host
    else
      raise "Request URI is collapsed : #{base_uri}"
    end
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

  def score(other : Request) : Int32
    Replay::Log.debug { "Comparing : #{self.base_index} and #{other.base_index}." }
    case other
    when HTTPRequest
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
    match_json_internal me, another, 0
  rescue e : JSON::ParseException
    0
  end

  private def match_json_internal(me : JSON::Any, other : JSON::Any, score : Int32) : Int32
    me.as_h.keys.reduce(score) do |acc, key|
      case value = other[key]
      when .as_s?
        if value = me[key].as_s?
          acc + 1
        end
      when .as_i?
        if value == me[key].as_i?
          acc + 1
        end
      when .as_bool?
        if value == me[key].as_bool?
          acc + 1
        end
      when .as_a?
        if value == me[key].as_a?
          acc + 1
        end
      when .as_f?
        if value == me[key].as_f?
          acc + 1
        end
      when .as_h?
        me[key].as_h?.try do |_|
          match_json_internal me[key], value, score
        end
      end
    end
    score
  end

  private def match_form(i : Request, other : Request) : Int32
    me = split_form(i.body)
    another = split_form(other.body)
    has_any_key = me.keys.find do |k|
      !another.keys.includes?(k)
    end
    has_any_key.try do |_|
      me.count do |k, v|
        another[k]?.try do |a|
          v == nil || a != v
        end
      end
    end || 0
  end

  private def split_form(body)
    body.split("&").map do |and|
      v = and.split("=")
      {v[0], v[1]?}
    end.to_h
  end

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
       (method_query == nil || method_query == true) &&
       (path_query == nil || path_query == true))
      self
    else
      nil
    end
  end
end
