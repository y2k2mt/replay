struct MockRecords
  include Records

  def initialize(@expected_record : Record? = nil)
  end

  def find(request : Request) : Record | NoIndexFound | CorruptedReplayResource | NoResourceFound
    @expected_record.not_nil!
  end
end

struct MockRequests
  include Requests

  def initialize(@expected_request : Request? = nil)
  end

  def from(io : IO) : RequestError | Request
    @expected_request || RequestError.new
  end

  def from(request_json : JSON::Any) : Request
    @expected_request.not_nil!
  end
end

class MockRecord
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

class MockRequest
  include Request

  def initialize(@base_index : String = "", @id_index : String = "", @metadatas : Hash(String, String) = {} of String => String, @expected_request : Request? = nil)
  end

  def id_index : String
    @id_index
  end

  def base_index : String
    @base_index
  end

  def ==(other : Request) : Bool
    (@expected_request.try { |e| e == other }) || false
  end

  def proxy
    ProxyError | Record
  end

  def metadatas : JSON::Any
    JSON.parse @metadatas.to_json
  end
end
