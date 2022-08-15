enum Protocol
  TCP
  HTTP
end

module HasProtocol
  def protocol : Protocol
  end
end

struct RequestError
end

module Requests
  include HasProtocol

  def from(io : IO) : RequestError | Request
  end
end

module Request
  def base_index : String
  end

  def ==(other : Request) : Bool
  end

  def proxy() ProxyError | Record
  end
end

module Record
  def response(io : IO)
  end
end

struct ProxyError
end

module Datastore
  def persist(request : Request, record : Record) : Void
  end

  def find(request : Request) : Record?
  end
end
