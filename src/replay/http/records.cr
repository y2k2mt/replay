class HTTPRecords
  include Records

  def initialize
  end

  def from(header : IO, body : IO, request : Request) : Record | NoResourceFound
    HTTPRecord.new(header, body, request)
  end
end
