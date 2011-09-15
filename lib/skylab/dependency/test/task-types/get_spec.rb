require File.expand_path('../helper', __FILE__)
require File.expand_path('../../../graph', __FILE__)

module Skylab::Dependency
  include Test::Support
  describe Graph do
    it "should work" do
      File.exist?(TEST_BUILD_DIR) and FileUtils.rm_rf(TEST_BUILD_DIR, :verbose => true)
      FileUtils.mkdir(TEST_BUILD_DIR, :verbose => true)
      Test::Support::StaticFileServer.start_unless_running
      graph = Graph.from_file(File.join(Test::Support::FIXTURES_DIR, 'depz1.json'))
      ui1 = Test::Support::UiTee.new
      ui2 = Test::Support::UiTee.new
      graph.run(ui1, { :build_dir => TEST_BUILD_DIR })
      graph.run(ui2, { :build_dir => TEST_BUILD_DIR })
      ui1.out[:buffer].to_str.should eq('')
      ui2.out[:buffer].to_str.should eq('')
      ui1.err[:buffer].to_str.should match(/read 419 bytes/)
      ui2.err[:buffer].to_str.should match(/skipping, exists/)
    end
  end
end
