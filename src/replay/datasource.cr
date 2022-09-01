module Datasource
  def persist(request : Request, record : Record) : Record
  end

  def find(request : Request) : Record?
  end
end
