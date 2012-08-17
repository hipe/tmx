require File.expand_path('../test-support', __FILE__)
require File.expand_path('../../../task-types/executable-file', __FILE__)


module Skylab::Dependency::TestSupport
  include Skylab::Dependency
  describe TaskTypes::ExecutableFile do
    module_eval &DESCRIBE_BLOCK_COMMON_SETUP
    let(:build_args) { { :executable_file => executable_file } }
    let(:context) { { } }
    subject do
      TaskTypes::ExecutableFile.new(build_args) do |t|
        t.context = context
        t.on_all do |e|
          $debug and $stderr.puts("_dbg: #{e.type}: #{e}")
          fingers[e.type].push unstylize(e.to_s)
        end
      end
    end
    context "with empty build args" do
      let(:build_args) { { } }
      it "raises an exception complaining of missing required attributes" do
        ->(){ subject.invoke }.should raise_exception(
          /missing required attribute: executable_file/
        )
      end
    end
    context "when pointing to an executable file" do
      let(:executable_file) { `which ruby`.strip }
      it "should emit a notice and return true" do
        r = subject.invoke
        r.should eql(true)
        fingers[:info].last.should match(/executable: .*\/ruby/)
      end
    end
    context "when pointing to a file not found" do
      let(:executable_file) { BUILD_DIR.join('not-a-file').to_s }
      it "should emit a notice and return false" do
        r = subject.invoke
        fingers[:info].last.should match(/executable does not exist.*not-a-file/)
      end
    end
    context "when pointing to a found, not executable file" do
      let(:executable_file) { FIXTURES_DIR.join('some-file.txt') }
      it "should emit a notice and return false" do
        r = subject.invoke
        fingers[:info].last.should match(/exists but is not executable.*some-file/)
      end
    end
  end
end

