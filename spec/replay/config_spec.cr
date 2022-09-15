require "../spec_helper"

describe Config do
  it "can get properties" do
    config = Config.new("https://www.example.org", 8010, Config::Mode::Record, "/home/foo/bar")
    config.base_dir_path.should eq("/home/foo/bar")
    config.port.should eq(8010)
    config.mode.should eq(Config::Mode::Record)
  end
  it "can get lazy properties" do
    config = Config.new("https://www.example.org", 8010, Config::Mode::Record, "/home/foo/bar")
    config.base_uri.should eq(URI.parse("https://www.example.org"))
    config.base_uri_host.should eq("www.example.org")
    config.records.should be_a(HTTPRecords)
    config.requests.should be_a(HTTPRequests)
    config.datasource.should be_a(FileSystemDatasource)
    config.error_handler.should be_a(HTTPErrorHandler)
  end
  it "cant get lazy properties with unknown protocol" do
    config = Config.new("unsupported://www.example.org", 8010, Config::Mode::Record, "/home/foo/bar")
    expect_raises(UnsupportedProtocolError) do
      config.records
    end
    expect_raises(UnsupportedProtocolError) do
      config.requests
    end
    expect_raises(UnsupportedProtocolError) do
      config.error_handler
    end
  end
end
