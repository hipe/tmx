require_relative 'test-support'

module Skylab::Dependency::TestSupport::Tasks

  describe TaskTypes::Executable do
    extend Tasks_TestSupport

    let(:context) { { } }
    let(:build_args) { {
      :executable => executable
    } }

    subject do
      TaskTypes::Executable.new( build_args ) { |t| wire! t }
    end

    context "requires some things" do
      let(:executable) { nil }
      it "and raises hell when it doesn't have them" do
        lambda { subject.invoke }.should raise_error(
          RuntimeError, /missing required attribute.*executable/
        )
      end
    end

    context "when checking an executable not in path" do
      let(:executable) { 'not-an-executable' }
      it "returns false and emits info" do
        r = subject.invoke
        r.should eql(false)
        fingers[:info].length.should eql(1)
        fingers[:info].last.should match(/not in PATH: not-an-executable/)
      end
    end

    context "when checking an executable in the path" do
      let(:executable) { 'ruby' }
      it "returns true and emits info" do
        r = subject.invoke
        r.should eql(true)
        fingers[:info].last.should match(/ruby$/)
      end
    end
  end
end
