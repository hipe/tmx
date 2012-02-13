require File.expand_path('../../test-support', __FILE__)
require 'skylab/code-molester/config/file'

describe ::Skylab::CodeMolester::Config::File do
  include ::Skylab::CodeMolester::TestSupport
  let(:klass) { ::Skylab::CodeMolester::Config::File }
  let(:subject) do
    o = klass.new(path)
    input_string and o.content = input_string
    o
  end
  let(:path) { TMPDIR.join('whatever') }
  let(:input_string) { }
  it { should respond_to(:valid?) }
  it { should respond_to(:invalid_reason) }
  context "with regards to validity/parsing" do
    context "out of the box" do
      it "is valid (because an empty file is)" do
        subject.valid?.should eql(true)
      end
      it "has one line (for even an empty file has one line)" do
        subject.lines.count.should eql(1)
        line = subject.lines.first
        line.text_value.should eql('')
      end
    end
    context "with a bunch of blank lines" do
      let(:input_string) { "\n  \n\t\n" }
      it "is valid" do
        v = subject.valid?
        subject.invalid_reason.should eql(nil)
        v.should eql(true)
        ll = subject.lines
        ll.size.should eql(4)
        subject.text_value.should eql(input_string)
      end
    end
  end
end

