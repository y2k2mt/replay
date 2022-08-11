module Request
  def to_index : Index
  end
end

enum Protocol
  HTTP
end

struct RequestError
end

module Requests
  def from(io : IO) : RequestError | Request
    RequestError.new
  end
end

module Index
  def base_index : String
  end
  def ==(other : Request) : Bool
  end
end

module Record
  def response(io : IO)
  end
end

struct ProxyError
end

module Datastore
  def persist(index : Index,record : Record) : Void
  end
  def find(index : Index) : Record?
  end
end

module Records
  def proxy(index : Index) ProxyError | Record
  end
  def find(index : Index) : Record?
    datastore.find(index)
  end
  protected def datastore : Datastore
  end
end

struct Context
  getter records : Records,requests : Requests,protocol : Protocol
  def initialize(@records : Records,@requests : Requests,@protocol : Protocol)
  end
end

module Recorder
  def self.record(io : IO,context : Context) : RequestError | ProxyError | Record
    case maybe_request = context.requests.from(io)
    when RequestError
      maybe_request
    when Request
      context.records.proxy(maybe_request.to_index)
    end
  end
end
