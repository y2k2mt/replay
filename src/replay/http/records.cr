class HTTPRecords
  include Records

  def initialize
  end

  def from(header : IO, body : IO, request : Request) : Record
    HTTPRecord.new(header, body, request)
  end
end
