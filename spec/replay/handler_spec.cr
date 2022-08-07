require "../spec_helper"

describe Replay::RecordingHandler do
  it "works" do
    temp_dir_path = "#{Dir.tempdir}/replay_server_spec/#{Random::Secure.hex}"
    Dir.mkdir_p(temp_dir_path)
    config = Config.new(
      base_uri = "http://www.example.com",
      port = 8080.to_i16,
      mode = Config::Mode::Record,
      base_dir_path = temp_dir_path
    )

    WebMock.stub(:post, "http://www.example.com/foo")
      .with(body: "bar=baz", headers: {"Host" => "www.example.com", "Content-Type" => "application/x-www-form-urlencoded"})
      .to_return(status: 200, body: "hello!", headers: {"X-OK" => "true"})

    recorder = Replay::RecordingHandler.new(config)
    context = HTTP::Server::Context.new(HTTP::Request.new(
      method = "POST",
      resource = "/foo",
      headers = HTTP::Headers{"Content-Type" => "application/x-www-form-urlencoded"},
      body = "bar=baz",
    ), HTTP::Server::Response.new(IO::Memory.new))

    recorder.call(context)

    actual_header_file = Dir.new("#{temp_dir_path}/indexes/").each_child.next
    actual_response_dir = Dir.new("#{temp_dir_path}/replies/").each_child
    actual_response_file = actual_response_dir.next
    actual_response_header_file = actual_response_dir.next
    actual_response_body = File.new("#{temp_dir_path}/replies/#{actual_response_file.to_s}").gets_to_end
    actual_response_body.should eq("hello!")
    FileUtils.rm_rf(temp_dir_path)
  end
end
