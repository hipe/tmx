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
    context "when input is bunch of blank lines" do
      let(:input_string) { "\n  \n\t\n" }
      it "it is valid" do
        subject.invalid_reason.should eql(nil)
        subject.lines.size.should eql(4)
        subject.text_value.should eql(input_string)
      end
    end
    context "when input is one comment" do
      let(:input_string) { "      # ha-blah" }
      it "it is valid" do
        subject.invalid_reason.should eql(nil)
        subject.lines.size.should eql(1)
        subject.lines.first.nt_name.should eql(:whitespace_line)
      end
    end
    context "when input is one assigmnent line" do
      def ok
        subject.invalid_reason.should eql(nil)
        subject.lines.size.should eql(1)
        @line = subject.lines.first
        @line.nt_name.should eql(:assignment_line)
      end
      def name
        @line.assignment_name
      end
      def value
        @line.assignment_value.text_value
      end
      def comment
        @line.comment.body.text_value
      end
      context("as the ideal, general case") do
       let(:input_string) { "foo=bar" }
       it "parses" do
         ok
         name.should eql('foo')
         value.should eql('bar')
       end
      end
      context("that has spaces and a comment") do
        let(:input_string) { "  foo= bar baz #boffo" }
        it "will parse it, stripping leading and trailing whitespace, and revealing the comment" do
          ok
          name.should eql('foo')
          value.should eql('bar baz')
          comment.should eql('boffo')
        end
      end
      context("that has no value at all") do
        let(:input_string) { "\t  foo_bar  =" }
        it "will have the empty string as a value" do
          ok
          name.should eql('foo_bar')
          value.should eql('')
        end
      end
      context("that has no value, but trailing whitespace") do
        let(:input_string) { " fooBar09   = \t#some comment\t " }
        it "still works" do
          ok
          name.should eql('fooBar09')
          value.should eql('')
          comment.should eql("some comment\t ")
        end
      end
    end
  end
end

