class HTTPRecords
  include Records

  def initialize
  end

  def from(header : IO, body : IO) : Record
    HTTPRecord.new(header, body)
  end
end
