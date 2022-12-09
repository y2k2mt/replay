require "../../spec_helper"

describe HTTPRequests do
  it "can get request via io" do
    io = IO::Memory.new(1024)
    headers = HTTP::Headers{"Content-Type" => "text/plain"}
    request = HTTP::Request.new("POST", "/hello", headers, "HELLO")
    request.to_io(io)
    actual = HTTPRequests.new(URI.parse "http://base.uri").from(IO::Memory.new(io.to_s)).as(IncomingHTTPRequest)
    actual.host_name.should eq("base.uri")
    actual.path.should eq("/hello")
    actual.method.should eq("POST")
    actual.body.should eq("HELLO")
    actual.headers["Content-Type"][0].should eq("text/plain")
  end
  it "can not get invalid request via io" do
    io = IO::Memory.new("NOT HTTP FORMAT")
    actual = HTTPRequests.new(URI.parse "http://base.uri").from(io)
    actual.should be_a(RequestError)
  end
  it "can get request via json" do
    json = %q{
{
  "id": "1770a0838932637cb823570c908552e4",
  "host": "base.uri",
  "method": "GET",
  "path": "/test",
  "indexed": {
    "headers": {
      "User-Agent": [
        "baz/1"
      ]
    },
    "params": {},
    "body": "HELLO"
  },
  "not_indexed": {
    "headers": {
      "Accept": [
        "*/*"
      ]
    },
    "params": {
      "q": "a",
      "b": "c"
    },
    "body": ""
  }
}
    }
    actual = HTTPRequests.new(URI.parse "http://base.uri").from(JSON.parse(json)).as(RecordedHTTPRequest)
    actual.host_name.should eq("base.uri")
    actual.path.should eq("/test")
    actual.method.should eq("GET")
    # returns only indexed
    actual.body.should eq("HELLO")
    actual.params.should eq({} of String => String)
    actual.headers["User-Agent"].first.should eq("baz/1")
  end
end
