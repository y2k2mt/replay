require "../../spec_helper"

describe HTTPRequest do
  it "can get properties via server request" do
    headers = HTTP::Headers{"Content-Type" => "text/plain"}
    request = HTTP::Request.new("POST", "/hello", headers, "HELLO")
    actual = HTTPRequest.new(request,URI.parse "http://base.uri")
    # Write to response
    actual.host_name.should eq("base.uri")
    actual.path.should eq("/hello")
    actual.method.should eq("POST")
    actual.body.should eq("HELLO")
    actual.headers["Content-Type"][0].should eq("text/plain")
    actual.base_index.should eq("ce3e48c460a779f1554cd6e845a5fadf8e2c9f3b5126c65207294508e2592f6e")
  end
end
