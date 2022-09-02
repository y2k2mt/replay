module Datasource
  def persist(request : Request, record : Record) : Record
  end

  def find(request : Request, requests : Requests) : Record | NoIndexFound | CorruptedReplayResource | NoResourceFound
  end
end
