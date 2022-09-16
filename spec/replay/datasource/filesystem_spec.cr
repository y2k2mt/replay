require "../../spec_helper"

describe FileSystemDatasource do
  it "can create resources" do
    test_file_dir = "#{Dir.tempdir}/replay_specs"
    requests = MockRequests.new
    records = MockRecords.new
    record = MockRecord.new({"foo" => "bar"}, "baz=qux")
    request = MockRequest.new(id_index: "id_index", base_index: "index", metadatas: {"foo" => "bar"})

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

  it "can retrive resources" do
    test_file_dir = "#{FileUtils.pwd}/spec/replay/datasource/filesystem_spec"
    requests = MockRequests.new
    records = MockRecords.new
    request = MockRequest.new("db0da", "db0da_1770a", {"foo" => "bar"})

    datasource = FileSystemDatasource.new(test_file_dir, records, requests)
    pp! actual = datasource.find(request)
  end
end
