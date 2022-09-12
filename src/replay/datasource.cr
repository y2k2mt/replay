module Datasource
  def persist(request : Request, record : Record) : Record
  end

  def get(request : Request) : Record | NoIndexFound | CorruptedReplayResource | NoResourceFound
  end

  def find(query : Array(String)) : Array(Record?)
  end
end
