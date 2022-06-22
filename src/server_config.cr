class ServerConfig
  enum Mode
    Record
    Replay
  end

  getter base_url, port, mode

  def initialize(@base_url : String, @port : Int16, @mode : Mode)
  end
end
