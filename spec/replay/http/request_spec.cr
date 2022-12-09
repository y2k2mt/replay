require "../../spec_helper"

describe IncomingHTTPRequest do
  it "can get properties via server request" do
    headers = HTTP::Headers{"Content-Type" => "text/plain"}
    request = HTTP::Request.new("POST", "/hello", headers, "HELLO")
    actual = IncomingHTTPRequest.new(request, URI.parse "http://base.uri")
    # Write to response
    actual.host_name.should eq("base.uri")
    actual.path.should eq("/hello")
    actual.method.should eq("POST")
    actual.body.should eq("HELLO")
    actual.body.should eq("HELLO")
    actual.headers["Content-Type"][0].should eq("text/plain")
    actual.base_index.should eq("ce3e48c460a779f1554cd6e845a5fadf8e2c9f3b5126c65207294508e2592f6e")
    actual_metadatas = actual.metadatas
    actual_metadatas["host"].should eq("base.uri")
    actual_metadatas["method"].should eq("POST")
    actual_metadatas["path"].should eq("/hello")
    actual_metadatas["indexed"]["body"].should eq("")
    actual_metadatas["not_indexed"]["body"].should eq("HELLO")
  end

  it "can compare json proeprties" do
    headers = HTTP::Headers{
      "Content-Type" => "application/json",
    }
    json = %q{
      {
        "foo":"bar",
        "baz":"qux",
        "hoge": {
          "fuga": 1,
          "moge":"bar",
          "baz" : [1,3,2]
        }
      }
    }

    another_json = %q{
      {
        "hoge": {
          "fuga": 1
        }
      }
    }
    request = HTTP::Request.new("POST", "/hello", headers, json)
    request1 = IncomingHTTPRequest.new(request, URI.parse "http://base.uri")
    request2 = RecordedHTTPRequest.new(id: "foo", base_uri: URI.parse("http://base.uri"), path: "/hello", method: "POST", headers: headers.to_h, body: another_json, params: {} of String => String)
    (request2.score(request1)).should eq 1
  end

  it "can get multiple properties via server request" do
    headers = HTTP::Headers{"Content-Type" => "text/plain"}
    request = HTTP::Request.new("POST", "/hello", headers, "HELLO")
    actual = IncomingHTTPRequest.new(request, URI.parse "http://base.uri")
    # Write to response
    actual.host_name.should eq("base.uri")
    actual.path.should eq("/hello")
    actual.method.should eq("POST")
    actual.body.should eq("HELLO")
    actual.body.should eq("HELLO")
    actual.headers["Content-Type"][0].should eq("text/plain")
    actual.base_index.should eq("ce3e48c460a779f1554cd6e845a5fadf8e2c9f3b5126c65207294508e2592f6e")
    actual_metadatas = actual.metadatas
    actual_metadatas["host"].should eq("base.uri")
    actual_metadatas["method"].should eq("POST")
    actual_metadatas["path"].should eq("/hello")
    actual_metadatas["indexed"]["body"].should eq("")
    actual_metadatas["not_indexed"]["body"].should eq("HELLO")
  end

  it "can compare json proeprties" do
    headers = HTTP::Headers{
      "Content-Type" => "application/json",
    }
    json = %q{
      {
        "foo":"bar",
        "baz":"qux",
        "hoge": {
          "fuga": 1,
          "moge":"bar",
          "baz" : [1,3,2]
        }
      }
    }

    another_json = %q{
      {
        "foo":"bar",
        "hoge": {
          "baz" : [1,3,2]
        }
      }
    }
    request = HTTP::Request.new("POST", "/hello", headers, json)
    request1 = IncomingHTTPRequest.new(request, URI.parse "http://base.uri")
    request2 = RecordedHTTPRequest.new(id: "foo", base_uri: URI.parse("http://base.uri"), path: "/hello", method: "POST", headers: headers.to_h, body: another_json, params: {} of String => String)
    (request2.score(request1)).should eq 2
  end

  it "can compare json proeprties" do
    headers = HTTP::Headers{
      "Content-Type" => "application/json",
    }
    json = %q{
      {
        "foo":"bar",
        "baz":"qux",
        "hoge": {
          "fuga": 1,
          "moge":"bar",
          "baz" : [1,3,2]
        }
      }
    }

    another_json = %q{
      {
        "hoge": {
          "fuga": 1
        }
      }
    }
    request = HTTP::Request.new("POST", "/hello", headers, json)
    request1 = IncomingHTTPRequest.new(request, URI.parse "http://base.uri")
    request2 = RecordedHTTPRequest.new(id: "foo", base_uri: URI.parse("http://base.uri"), path: "/bye", method: "POST", headers: headers.to_h, body: another_json, params: {} of String => String)
    (request2.score(request1)).should eq -1
  end

  it "can not compare json proeprties" do
    headers = HTTP::Headers{
      "Content-Type" => "application/json",
    }
    json = %q{
      {
        "foo":"bar",
        "baz":"qux",
        "hoge": {
          "fuga": 1,
          "moge":"bar",
          "baz" : [1,3,2]
        }
      }
    }
    another_json = %q{
      {
        "foo":"bar",
        "hoge": {
          "fuga": 2,
          "baz" : [1,3,2]
        }
      }
    }
    request = HTTP::Request.new("POST", "/hello", headers, json)
    request1 = IncomingHTTPRequest.new(request, URI.parse "http://base.uri")
    request2 = RecordedHTTPRequest.new(id: "foo", base_uri: URI.parse("http://base.uri"), path: "/hello", method: "POST", headers: headers.to_h, body: another_json, params: {} of String => String)
    (request2.score(request1)).should eq -1
  end

  it "can compare form proeprties" do
    headers = HTTP::Headers{
      "Content-Type" => "application/x-www-form-urlencoded",
    }
    form = "foo=bar&baz=qux&fuga=1"
    another_form = "foo=bar&fuga=1"

    request = HTTP::Request.new("POST", "/hello", headers, form)
    request1 = IncomingHTTPRequest.new(request, URI.parse "http://base.uri")
    request2 = RecordedHTTPRequest.new(id: "foo", base_uri: URI.parse("http://base.uri"), path: "/hello", method: "POST", headers: headers.to_h, body: another_form, params: {} of String => String)
    (request2.score(request1)).should eq 2
  end
  it "can not compare form proeprties" do
    headers = HTTP::Headers{
      "Content-Type" => "application/x-www-form-urlencoded",
    }
    form = "foo=bar&baz=qux&fuga=1"
    another_form = "foo=baz&fuga=1"
    request = HTTP::Request.new("POST", "/hello", headers, form)
    request1 = IncomingHTTPRequest.new(request, URI.parse "http://base.uri")
    request2 = RecordedHTTPRequest.new(id: "foo", base_uri: URI.parse("http://base.uri"), path: "/hello_foo", method: "POST", headers: headers.to_h, body: another_form, params: {} of String => String)
    (request2.score(request1)).should eq -1
  end
end
