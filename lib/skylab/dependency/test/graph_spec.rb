require File.expand_path('../helper', __FILE__)
require File.expand_path('../../graph', __FILE__)
require 'ruby-debug'

module Skylab
  module Dependency
    include Test::Support
    describe Graph do
      it "should do this big thing" do
        File.exist?(TEST_BUILD_DIR) and FileUtils.rm_rf(TEST_BUILD_DIR, :verbose => true)
        FileUtils.mkdir(TEST_BUILD_DIR, :verbose => true)
        StaticFileServer.start_unless_running
        graph = Graph.from_file(File.join(FIXTURES_DIR, 'depz2.json'))
        ui1 = Test::Support::UiTee.new
        graph.run(ui1, { :build_dir => TEST_BUILD_DIR })
        ui1.out[:buffer].to_str.should eq('')
        ui1.err[:buffer].to_str.should match(%r{mkdir -p .+tmp/build_dir/local})
      end
    end
  end
end