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
      it "has no content items" do
        subject.content_items.size.should eql(0)
        subject.content.should eql('')
      end
    end
    context "when input is bunch of blank lines" do
      let(:input_string) { "\n  \n\t\n" }
      it "it is valid" do
        subject = self.subject
        subject.invalid_reason.should eql(nil)
        subject.content_items.size.should eql(0)
        subject.text_value.should eql(input_string)
      end
    end
    context "when input is one comment" do
      let(:input_string) { "      # ha-blah" }
      it "it is valid" do
        subject.invalid_reason.should eql(nil)
        subject.content_items.size.should eql(0)
        subject.content_tree.elements.first.nt_name.should eql(:whitespace_line)
      end
    end
    context "when input is one assigmnent line" do
      before(:each) do
        subject.invalid_reason.should eql(nil)
        subject.content_items.size.should eql(1)
        @line = subject.content_items.first
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
          name.should eql('foo')
          value.should eql('bar')
        end
      end
      context("that has spaces and a comment") do
        let(:input_string) { "  foo= bar baz #boffo" }
        it "will parse it, stripping leading and trailing whitespace, and revealing the comment" do
          name.should eql('foo')
          value.should eql('bar baz')
          comment.should eql('boffo')
        end
      end
      context("that has no value at all") do
        let(:input_string) { "\t  foo_bar  =" }
        it "will have the empty string as a value" do
          name.should eql('foo_bar')
          value.should eql('')
        end
      end
      context("that has no value, but trailing whitespace") do
        let(:input_string) { " fooBar09   = \t#some comment\t " }
        it "still works" do
          name.should eql('fooBar09')
          value.should eql('')
          comment.should eql("some comment\t ")
        end
      end
    end # assignment line
    context "when input is a valid section line" do
      before(:each) do
        subject.invalid_reason.should eql(nil)
        (ll = subject.content_items).count.should eql(1)
        (line = ll.first).nt_name.should eql(:section)
        @line = line
      end
      def section_name
        @line.section_name
      end
      context "in the ideal, general case" do
        let(:input_string) { "[foo]" }
        it "works" do
          section_name.should eql('foo')
        end
      end
      context "with lots of spaces and tabs everywhere" do
        let(:input_string) { "  \t [\t 09foo.bar ]   \t" }
        it "works" do
          section_name.should eql('09foo.bar')
        end
      end
    end
  end # validity / parsing
  context "With regards to rendering parse errors" do
    before(:each) do
      subject.valid?.should eql(false)
    end
    let(:invalid_reason) { subject.invalid_reason.to_s }
    context "if you had an invalid section name on e.g. the third line" do
      let(:input_string) { "foo=bar\n#ok\n[foo/bar]\n# one more line" }
      it "it will report line number and context and expecting" do
        invalid_reason.should eql('Expecting "]" at the end of "[foo/" at line 3')
      end
    end
    context "if you had something invalid at the very first character" do
      let(:input_string) { '{' }
      it "will do the same as above" do
        invalid_reason.should eql('Expecting "[", "#" or "\n" at beginning of line at line 1')
      end
    end
    context "if you had something invalid as the very last character" do
      let(:input_string) { "\n\n# foo\n  }" }
      it "will do the same as above"  do
        invalid_reason.should eql('Expecting "[", "#" or "\n" at the end of "  }" at line 4')
      end
    end
  end
  context "As for getting values" do
    let(:config) do
      klass.new(
        :path     => path,
        :content  => content
      )
    end
    context "with a file with one value" do
      let(:content) { 'foo = bar' }
      it "can get it" do
        config['foo'].should eql('bar')
      end
      it "we don't do magic conversion to symbols for you" do
        config[:foo].should eql(nil)
      end
      it "will get nil if it asks for a name that isn't there" do
        config['fo'].should eql(nil)
      end
    end
    context "with a file with one section" do
      let(:context) { "foo = bar\n [bizzo]\nfoo = biz\n[bazzo]foo = buz" }
      #  it "does some magic hackery" do

      # end
    end
  end
  context "As for setting values" do
  end
end # describe

