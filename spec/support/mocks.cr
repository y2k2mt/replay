struct MockRecords
  include Records
end

struct MockRequests
  include Requests
end

struct MockRecord
  include Record

  def initialize(@metadatas : Hash(String, String), @entity : String)
  end

  def response(io : IO)
    # NOP
  end

  def metadatas : JSON::Any
    JSON.parse @metadatas.to_json
  end

  def entity : String
    @entity
  end
end

struct MockRequest
  include Request

  def initialize(@base_index : String, @metadatas : Hash(String, String))
  end

  def id_index : String
    "id_#{@base_index}"
  end

  def base_index : String
    @base_index
  end

  def ==(other : Request) : Bool
  end

  def proxy
    ProxyError | Record
  end

  def metadatas : JSON::Any
    JSON.parse @metadatas.to_json
  end
end
