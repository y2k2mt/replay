module Request
  def id_index : String
  end

  def base_index : String
  end

  def score(other : Request) : Int32
    -1
  end

  def proxy
    ProxyError | Record
  end

  def metadatas : JSON::Any
  end
end
