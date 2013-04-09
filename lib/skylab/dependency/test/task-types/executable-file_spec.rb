require_relative 'test-support'

module Skylab::Dependency::TestSupport::Tasks

  # Quickie!

  describe TaskTypes::ExecutableFile do

    extend Tasks_TestSupport

    let(:build_args) { { :executable_file => executable_file } }

    let(:context) { { } }

    let :subject do
      TaskTypes::ExecutableFile.new( build_args ) { |t| wire! t }
    end

    context "with empty build args" do
      let(:build_args) { { } }
      it "raises an exception complaining of missing required attributes" do
        ->(){ subject.invoke }.should raise_error(
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
        r.should eql( false )
      end
    end

    context "when pointing to a found, not executable file" do
      let(:executable_file) { FIXTURES_DIR.join('some-file.txt') }
      it "should emit a notice and return false" do
        r = subject.invoke
        fingers[:info].last.should match(/exists but is not executable.*some-file/)
        r.should eql( false )
      end
    end
  end
end
