module Requests
  def from(io : IO) : RequestError | Request
  end

  def from(json : JSON::Any) : Request
  end
end
