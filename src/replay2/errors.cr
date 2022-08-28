struct RequestError
end

struct ProxyError
end

struct UnsupportedProtocolError
  getter protocol
  def initialize(@protocol : String?)
  end
end
