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

module Indexes
  include HasProtocol

  def from(io : IO) : RequestError | Index
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
  def persist(index : Index, record : Record) : Void
  end

  def find(index : Index) : Record?
  end
end

module Records
  include HasProtocol

  def proxy(index : Index)
    ProxyError | Record
  end
end

struct Context
  getter records : Records, indexes : Indexes

  def initialize(@records : Records, @indexes : Indexes)
  end
end

module Recorder
  def self.record(io : IO, context : Context) : RequestError | ProxyError | Record
    case maybe_index = context.indexes.from(io)
    when RequestError
      maybe_index
    when Request
      context.records.proxy(maybe_index)
    end
  end
end
