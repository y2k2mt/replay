module Request
  def id_index : String
  end

  def base_index : String
  end

  def ==(other : Request) : Bool
  end

  def proxy
    ProxyError | Record
  end

  def metadatas : JSON::Any
  end
end
