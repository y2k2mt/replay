require "../../spec_helper"

class MockRecords
  include Records
end

class MockRequests
  include Requests
end

struct MockRecord
  include Record

  def initialize(@metadatas : Hash(String, String), @entity : String)
  end

  def response(io : IO)
    # NOP
  end

  def metadatas : JSON::Any
    JSON.parse @metadatas.to_json
  end

  def entity : String
    @entity
  end
end

struct MockRequest
  include Request

  def initialize(@base_index : String, @metadatas : Hash(String, String))
  end

  def id_index : String
    "id_#{@base_index}"
  end

  def base_index : String
    @base_index
  end

  def ==(other : Request) : Bool
  end

  def proxy
    ProxyError | Record
  end

  def metadatas : JSON::Any
    JSON.parse @metadatas.to_json
  end
end

describe FileSystemDatasource do
  it "can get properties" do
    test_file_dir = "#{Dir.tempdir}/replay_specs"
    requests = MockRequests.new
    records = MockRecords.new
    record = MockRecord.new({"foo" => "bar"}, "baz=qux")
    request = MockRequest.new("index", {"foo" => "bar"})

    datasource = FileSystemDatasource.new(test_file_dir, records, requests)
    datasource.persist(request, record)
    actual_index_file = File.new("#{test_file_dir}/indexes/id_index").gets_to_end
    actual_reply_body_file = File.new("#{test_file_dir}/replies/id_index").gets_to_end
    actual_reply_header_file = File.new("#{test_file_dir}/replies/id_index_headers").gets_to_end

    actual_index_file.should eq("{\n  \"foo\": \"bar\"\n}")
    actual_reply_header_file.should eq("{\"foo\":\"bar\"}")
    actual_reply_body_file.should eq("baz=qux")
  ensure
    FileUtils.rm_rf("#{Dir.tempdir}/replay_specs")
  end
end
