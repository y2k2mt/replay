struct MockRecords
  include Records

  def initialize(@expected_record : Record? = nil)
  end

  def from(headers : IO, body : IO, request : Request)
    @expected_record || NoResourceFound.new("Record unsetted")
  end
end

struct MockRequests
  include Requests

  def initialize(@expected_request : Request? = nil)
  end

  def from(io : IO)
    @expected_request || RequestError.new
  end

  def from(request_json : JSON::Any) : Request
    @expected_request || raise "Expecred request is not set."
  end
end

class MockRecord
  include Record

  def initialize(@metadatas : Hash(String, String), @entity : String)
  end

  def response(io : IO)
    # NOP
  end

  def metadatas
    JSON.parse(@metadatas.to_json)
  end

  def entity
    @entity
  end
end

class MockRequest
  include Request

  def initialize(@base_index : String = "", @id_index : String = "", @metadatas : Hash(String, String) = {} of String => String)
  end

  def id_index
    @id_index
  end

  def base_index
    @base_index
  end

  def ==(other : Request)
    self.hash == other.hash
  end

  def proxy
  end

  def metadatas
    JSON.parse @metadatas.to_json
  end

  def body
    ""
  end

  def headers
    ""
  end

  def params
    ""
  end
end
