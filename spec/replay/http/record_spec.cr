require "../../spec_helper"

describe HTTPRecord do
  it "can get properties via client response" do
    headers = HTTP::Headers{"Content-Type" => "text/plain"}
    request = MockRequest.new("db0da", "db0da_1770a", {"foo" => "bar"})
    client_response = HTTP::Client::Response.new(200, "Hello", headers)
    record = HTTPRecord.new(client_response,request)
    actual_response = IO::Memory.new
    # Write to response
    record.response(actual_response)
    actual_response.to_s.should eq("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 5\r\n\r\nHello")
    actual_body = record.entity
    actual_body.should eq("Hello")
    actual_metadatas = record.metadatas
    actual_metadatas["headers"]["Content-Type"].should eq("text/plain")
    actual_metadatas["status"].should eq(200)
  end
  it "can get properties via json formatted response" do
    body = IO::Memory.new "HELLO"
    header = IO::Memory.new "{\"headers\":{\"Content-Type\":\"text/plain\",\"Server\":\"test_server\",\"Set-Cookie\":\"foo=bar\"},\"status\":201}"
    request = MockRequest.new("db0da", "db0da_1770a", {"foo" => "bar"})
    record = HTTPRecord.new(header, body, request)
    # Write to response
    actual_body = record.entity
    actual_body.should eq("HELLO")
    actual_metadatas = record.metadatas
    actual_metadatas["headers"]["Content-Type"].should eq("text/plain")
    actual_metadatas["headers"]["Server"].should eq("test_server")
    actual_metadatas["headers"]["Set-Cookie"].should eq("foo=bar")
    actual_metadatas["status"].should eq(201)
  end
end
