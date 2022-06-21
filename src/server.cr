class Server
  @server = HTTP::Server.new(handlers)

  def self.handlers : Array(HTTP::Handler)
    [
      Parrot::Handler.new,
    ] of HTTP::Handler
  end

  def start : Void
    address = @server.bind_tcp 8080
    Parrot::Log.info { "Listening on http://#{address}" }
    @server.listen
  end

  def stop : Void
    @server.close
  end
end
