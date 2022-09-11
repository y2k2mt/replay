module Datasource
  def persist(request : Request, record : Record) : Record
  end

  def get(request : Request) : Record | NoIndexFound | CorruptedReplayResource | NoResourceFound
  end
end
