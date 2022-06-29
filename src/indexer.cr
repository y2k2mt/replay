module Indexer
  def index(record : Record) : Record
  end
  def request_match(request) : Bool
  end
end

class FileSystemIndexer
  include Indexer
  def request_match(request)
    false
  end
  def index(record : Record)
  end
end
