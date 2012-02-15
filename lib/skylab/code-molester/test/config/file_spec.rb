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
  let(:config) do
    klass.new(
      :path     => path,
      :content  => content
    )
  end
  let(:path) { TMPDIR.join('whatever') }
  let(:input_string) { }
  def parses_ok
    config.invalid_reason.should eql(nil)
    config.valid?.should eql(true)
  end
  def unparses_ok
    t = config.content_tree
    unp = t.unparse
    par = content
    unp.should eql(par)
  end
  def parses_and_unparses_ok
    parses_ok
    unparses_ok
  end
  it { should respond_to(:valid?) }
  it { should respond_to(:invalid_reason) }
  context "with regards to validity/parsing" do
    context "out of the box" do
      it "is valid (because an empty file is)" do
        subject.valid?.should eql(true)
      end
      it "has no content items" do
        subject = self.subject
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
        subject.unparse.should eql(input_string)
      end
    end
    context "when input is one comment" do
      let(:input_string) { "      # ha-blah" }
      it "it is valid" do
        subject.invalid_reason.should eql(nil)
        subject.content_items.size.should eql(0)
        subject.content.should eql("      # ha-blah")
      end
    end
    context "when input is one assigmnent line" do
      before(:each) do
        subject.invalid_reason.should eql(nil)
        subject.content_items.size.should eql(1)
        @line = subject.content_items.first
        @line.symbol_name.should eql(:assignment_line)
      end
      def name
        @line.detect(:name).last
      end
      def value
        @line.detect(:value).last
      end
      def comment
        @line.detect(:comment).detect(:body).unparse
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
        (line = ll.first).symbol_name.should eql(:section)
        @line = line
      end
      def section_name
        @line.detect(:header).detect(:section_line).detect(:name).last
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
        invalid_reason.should eql('Expecting "#", "\n" or "[" at beginning of line at line 1')
      end
    end
    context "if you had something invalid as the very last character" do
      let(:input_string) { "\n\n# foo\n  }" }
      it "will do the same as above"  do
        invalid_reason.should eql('Expecting "#", "\n" or "[" at the end of "  }" at line 4')
      end
    end
  end
  context "Basic overall grammar check:" do
    context "grammar check: many values" do
      let(:content) {"a=b\nc=d\ne=f"}
      specify { parses_and_unparses_ok }
    end
    context "grammar check: one section" do
      let(:content) {'[nerp]'}
      specify { parses_and_unparses_ok }
    end
    context "grammar check: two sections" do
      let(:content) { "[nerp]\n[derp]" }
      specify { parses_and_unparses_ok }
    end
    context "grammar check: blearg" do
      let(:content) { "foo = bar\n [bizzo]\nfoo = biz\n[bazzo]\nfoo = buz" }
      specify { parses_and_unparses_ok }
    end
  end
  context "As for getting values" do
    context "with a file with one value" do
      let(:content) { 'foo = bar' }
      it "can get it" do
        config['foo'].should eql('bar')
      end
      context "if you use a symbol for a key" do
        it "we don't do magic conversion for you, in fact it throws for now" do
          lambda { config[:foo] }.should raise_exception(
            TypeError, /can't convert Symbol into Integer/)
        end
      end
      it "will get nil if it asks for a name that isn't there" do
        config['fo'].should eql(nil)
      end
    end
    context "with a file with some sections" do
      let(:content) { "foo = bar\n [bizzo]\nfoo = biz\n[bazzo]\nfoo = buz" }
      specify { parses_ok }
      context "when you use [] to get a section that exists" do
        let(:subject) { config['bizzo'] }
        specify { subject.should be_kind_of(::Skylab::CodeMolester::Config::Section) }
        specify { subject.section_name.should eql('bizzo') }
        context "when you use [] to get a child value that exists" do
          it "works" do
            o = subject['foo']
            o.should eql('biz')
          end
        end
      end
    end
  end
  context "As for setting values" do
    before(:all) do
      TMPDIR.debug = false
    end
    before(:each) do
      TMPDIR.prepare
    end
    context "if you start with a config file that doesn't exist" do
      let(:path) { TMPDIR.join("my-config.conf") }
      let(:config) { klass.new(:path => path) }
      it "It knows it doesn't exist, and reports having the empty string as content" do
        config.exist?.should eql(false)
        config.content.should eql('')
      end
      it "It sees itself as valid, and will even show you a parse tree" do
        config.valid?.should eql(true)
        config.content_tree.should be_kind_of(Array)
      end
      context "if you set its content explicitly with a string" do
        let (:want_content) do
          <<-HERE.deindent
            times = fun
            [work]
              times = funner
            [play]
              times = funnest
          HERE
        end
        before(:each) do
          config.content = want_content
        end
        it "lets you access the values even tho the file hasn't been written yet" do
          config['times'].should eql('fun')
          config['work']['times'].should eql('funner')
          config['play']['times'].should eql('funnest')
          config['nope'].should eql(nil)
          config['work']['nope'].should eql(nil)
        end
        context "lets you add new values" do
          it "to the root node" do
            config['new_item'] = 'new value'
            config.content.split("\n")[0,2].join("\n").should eql(<<-HERE.deindent)
              times = fun
              new_item = new value
            HERE
          end
          it "to existing child nodes"
          it "it lets you crate new empty sections"
        end
      end
    end
  end
end # describe

