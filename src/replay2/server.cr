class Server
  def initialize(@config : Config)
    @server = TCPServer.new("localhost", 8899)
  end

  def start : Void
    while client = @server.accept?
      spawn handle_client(client)
    end
  end

  def handle_client(io)
    maybe_record = Recorder.record(io)
    case maybe_record
    when Record
      record.response(io)
    else
      # response err
    end
  end

  def stop : Void
    @server.close
  end
end
