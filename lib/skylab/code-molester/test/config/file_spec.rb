require_relative '../test-support'

module ::Skylab::CodeMolester::TestSupport

  include ::Skylab::CodeMolester::TestSupport::CONSTANTS

# ..

describe ::Skylab::CodeMolester::Config::File do

  extend ::Skylab::CodeMolester::TestSupport

  let(:klass) { CodeMolester::Config::File::Model }

  let :subject do
    klass.new path: path,
            string: ( input_string if input_string )
  end

  let :config do
    klass.new path: path,
            string: content
  end

  let(:content) { }
  let(:path) { TMPDIR.join 'whatever' }
  let(:input_string) { }
  def parses_ok
    config.invalid_reason.should eql(nil)
    config.valid?.should eql(true)
  end
  def unparses_ok
    t = config.sexp
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
        subject.string.should eql('')
      end
    end
    context "when input is bunch of blank lines" do
      let(:input_string) { "\n  \n\t\n" }
      it "it is valid" do
        subject = self.subject
        subject.invalid_reason.should eql(nil)
        subject.content_items.size.should eql(0)
        subject.string.should eql(input_string)
      end
    end
    context "when input is one comment" do
      let(:input_string) { "      # ha-blah" }
      it "it is valid" do
        subject.invalid_reason.should eql(nil)
        subject.content_items.size.should eql(0)
        subject.string.should eql("      # ha-blah")
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
      def section_name_node
        @line.detect(:header).detect(:section_line).detect(:name).last
      end
      context "in the ideal, general case" do
        let(:input_string) { "[foo]" }
        it "works" do
          section_name_node.should eql('foo')
        end
      end
      context "with lots of spaces and tabs everywhere" do
        let(:input_string) { "  \t [\t 09foo.bar ]   \t" }
        it "works" do
          section_name_node.should eql('09foo.bar ') # (per the grammar .. but meh idc)
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
      let(:input_string) { "foo=bar\n#ok\n[foo/bar]]\n# one more line" }
      it "it will report line number and context and expecting" do
        invalid_reason.should match(
          %r{^expecting.+in line 3 at the end of "\[foo/bar\]\]"}i )
      end
    end
    context "if you had something invalid at the very first character" do
      let(:input_string) { '{' }
      it "will do the same as above" do
        invalid_reason.should eql(
          'Expecting "#", "\n" or "[" at the beginning of line 1' )
      end
    end
    context "if you had something invalid as the very last character" do
      let(:input_string) { "\n\n# foo\n  }" }
      it "will do the same as above" do
        invalid_reason.should eql(
          'Expecting "#", "\n" or "[" in line 4 at the end of "  }"' )
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
            ::TypeError, /no implicit conversion of Symbol into Integer/ )
        end
      end
      it "will get nil if it asks for a name that isn't there" do
        # this used to be wonky when we hacked session assignment differently
        config['fo'].should eql(nil)
      end
    end
    context "HOWEVER with the 'value_items' pseudoclass" do
      let(:content) { "foo = bar\nbiff = baz\n[allo]" }
      it "you can see its keys like a hash" do
        config.value_items.keys.should eql(%w(foo biff))
      end
      it "you can iterate over its values like a sexp" do
        ks = %w(biff foo)
        vs = %w(baz bar)
        config.value_items.each do |item|
          item.key.should   eql(ks.pop)
          item.value.should eql(vs.pop)
        end
      end
      it "you can iterate over its values like a hash" do
        ks = %w(biff foo)
        vs = %w(baz bar)
        config.value_items.each do |k, v|
          k.should eql(ks.pop)
          v.should eql(vs.pop)
        end
      end
      it "you can access its values like a hash (note this returns values not nodes)" do
        config.value_items['foo'].should eql('bar')
      end
      it "accessing values that don't exist will not create bs" do
        config.value_items['baz'].should eql(nil)
      end
      it "you can set existing values" do
        config.value_items['foo'] = 'blamo'
        config.value_items['foo'].should eql('blamo')
        config.string.split("\n").first.should eql("foo = blamo")
      end
      it "you can create new values" do
        config['bleuth'] = 'michael'
        config.string.should eql(<<-HERE.unindent.strip)
          foo = bar
          biff = baz
          bleuth = michael
          [allo]
        HERE
      end
    end
    context "with a file with some sections" do
      let(:content) { "foo = bar\n [bizzo]\nfoo = biz\n[bazzo]\nfoo = buz" }
      specify { parses_ok }
      context "when you use [] to get a section that exists" do
        let(:subject) { config['bizzo'] }
        specify { subject.should be_kind_of(CodeMolester::Config::Sexps::Section) }
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
    before :each do
      TMPDIR.prepare
    end
    context "if you start with a config file that doesn't exist" do
      let(:path) { TMPDIR.join "my-config.conf" }
      def is_valid
        config.valid?.should eql(true)
        config.sexp.should be_kind_of(Array)
      end
      it "It knows it doesn't exist, and the string() of it will be the empty string" do
        config.exist?.should eql(false)
        config.string.should eql('')
      end
      it "It sees itself as valid, and will even show you a parse tree" do
        is_valid
      end
      context "if you build the instance with a chunky string of content" do
        let :content do
          <<-HERE.unindent
            who = hah
              boo = bah
            [play]
              times = fun
            [work]
              times = funner # good times here
          HERE
        end
        it "lets you access the values even tho the file hasn't been written yet" do
          config['boo'].should eql('bah')
          config['work']['times'].should eql('funner')
          config['play']['times'].should eql('fun')
          config.key?('nope').should eql(false)
          config['nope'].should eql(nil)
          config['work'].key?('nope').should eql(false)
          config['work']['nope'].should eql(nil)
        end
        context "lets you add new values" do
          it "to the root node (note the inherited whitespace)" do
            config['new_item'] = 'new value'
            config.string.split("\n")[0,3].join("\n").should eql(<<-HERE.unindent.strip)
              who = hah
                boo = bah
                new_item = new value
            HERE
          end
          it "to existing child nodes (note the unparsing of one section only!)" do
            config['work']['nerpus'] = 'derpus'
            config['work'].unparse.strip.should eql(<<-HERE.unindent.strip)
              [work]
                times = funner # good times here
                nerpus = derpus
            HERE
          end
          it "lets you create a section by assigning a hash to it" do
            last_part = ->(s) { s.match(/good times here(.+)\z/m)[1] }
            last_part[config.string].should eql("\n")
            config['goal'] ||= {}
            config['goal']['dream'] = 'deadline'
            last_part[config.string].should eql(<<-HERE.gsub(/^(  ){6}/, ''))

            [goal]
              dream = deadline
            HERE
          end
        end
      end
    end
  end
end # describe
# ..
end
