module Errors
  def response_error(output : IO, error : Object? = nil) : Void
  end
end

struct RequestError
end

struct ProxyError
end

class UnsupportedProtocolError < Exception
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
