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
    maybe_record = Recorder.record(io,HTTPRequests.new(@config))
    case maybe_record
    when Record
      maybe_record.response(io)
    else
      pp maybe_record
      # response err
    end
  end

  def stop : Void
    @server.close
  end
end
