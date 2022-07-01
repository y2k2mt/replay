module Indexer
  def index(record : Record) : Record | IndexError
    IndexError.new
  end

  def request_match(request) : Bool
    false
  end

  class IndexError
    def message : String
      "Indexing error"
    end
  end
end

class FileSystemIndexer
  include Indexer
end
