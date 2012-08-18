require File.expand_path('../test-support', __FILE__)
require 'skylab/dependency/task-types/executable'

module Skylab::Dependency::TestSupport

  include ::Skylab::Dependency
  describe TaskTypes::Executable do
    module_eval &DESCRIBE_BLOCK_COMMON_SETUP
    let(:context) { { } }
    let(:build_args) { {
      :executable => executable
    } }

    subject do
      TaskTypes::Executable.new(build_args) do |o|
        o.on_all { |e| fingers[e.type].push unstylize(e.to_s) }
        o.context = context
      end
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
        fingers[:info].size.should eql(1)
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

