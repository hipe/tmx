require File.expand_path('../helper', __FILE__)
require File.expand_path('../../../graph', __FILE__)

module Skylab::Dependency
  describe Graph do
    it "should work" do
      build_dir = File.join(Test::Support::TEST_ROOT_DIR, 'tmp/build_dir')
      if File.exist?(build_dir)
        FileUtils.rm_rf(build_dir, :verbose => true)
      end
      FileUtils.mkdir(build_dir, :verbose => true)
      Test::Support::StaticFileServer.start_unless_running
      graph = Graph.from_file(File.join(Test::Support::FIXTURES_DIR, 'deps1.json'))
      ui1 = Test::Support::UiTee.new
      ui2 = Test::Support::UiTee.new
      graph.run(ui1, { :build_dir => build_dir })
      graph.run(ui2, { :build_dir => build_dir })
      ui1.out[:buffer].to_str.should eq('')
      ui2.out[:buffer].to_str.should eq('')
      ui1.err[:buffer].to_str.should match(/read 419 bytes/)
      ui2.err[:buffer].to_str.should match(/skipping, exists/)
    end
  end
end
