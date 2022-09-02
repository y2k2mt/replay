struct RequestError
end

struct ProxyError
end

struct UnsupportedProtocolError
  getter protocol

  def initialize(@protocol : String?)
  end
end

struct NoIndexFound
  getter index

  def initialize(@index : String)
  end
end

struct NoResourceFound
  getter index

  def initialize(@index : String)
  end
end

struct CorruptedReplayResource
  getter index

  def initialize(@index : String)
  end
end
