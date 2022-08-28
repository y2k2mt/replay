module Requests
  def from(io : IO) : RequestError | Request
  end
end

module Request
  def base_index : String
  end

  def ==(other : Request) : Bool
  end

  def proxy
    ProxyError | Record
  end
end

module Record
  def response(io : IO)
  end
end

module Datasource
  def persist(request : Request, record : Record) : Void
  end

  def find(request : Request) : Record?
  end
end
