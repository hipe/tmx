require_relative 'file/test-support'

module Skylab::CodeMolester::TestSupport::Config::File

describe "[cm] config file" do

  extend TS_

  let :content do
  end

  let :path do
    tmpdir.join 'whatever'
  end

  let :input_string do
  end

  it "should respond to valid?" do
    subject.should be_respond_to :valid?
  end

  it "should respond_to invalid_reason" do
    subject.should be_respond_to :invalid_reason
  end

  context "with regards to validity/parsing" do

    context "out of the box" do

      it "is valid (because an empty file is)" do
        subject.valid?.should eql(true)
      end

      it "has no content items" do
        subject = self.subject
        subject.content_items.length.should be_zero
        subject.string.should eql('')
      end
    end

    context "when input is bunch of blank lines" do

      let(:input_string) { "\n  \n\t\n" }

      it "it is valid" do
        subject = self.subject
        subject.invalid_reason.should eql(nil)
        subject.content_items.length.should be_zero
        subject.string.should eql(input_string)
      end
    end

    context "when input is one comment" do

      let(:input_string) { "      # ha-blah" }

      it "it is valid" do
        subject.invalid_reason.should eql(nil)
        subject.content_items.length.should be_zero
        subject.string.should eql("      # ha-blah")
      end
    end

    context "when input is one assigmnent line" do

      before(:each) do
        subject = self.subject
        subject.invalid_reason.should eql(nil)
        subject.content_items.length.should eql 1
        @line = subject.content_items.first
        @line.symbol_i.should eql(:assignment_line)
      end

      def name
        @line.child( :name ).last
      end

      def value
        @line.child( :value ).last
      end

      def comment
        @line.child( :comment ).child( :body ).unparse
      end

      context "as the minimal normative case" do

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

      before :each do
        subj = subject
        subj.invalid_reason.should be_nil
        ci = subj.content_items
        ci.length.should eql 1
        _line = ci.first
        _line.symbol_i.should eql :section
        @line = _line
      end

      def section_name_node
        @line.child( :header ).child( :section_line ).child( :name ).last
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

  context "As for getting values" do

    context "with a file with one value" do

      let(:content) { 'foo = bar' }

      it "can get it" do
        config['foo'].should eql('bar')
      end

      context "if you use a symbol for a key" do
        it "we don't do magic conversion for you, in fact it throws for now" do
          _rx = /\Ano implicit conversion of 'foo' into String\b/
          cfg = config
          -> do
            cfg[ :foo ]
          end.should raise_error ::TypeError, _rx
        end
      end

      it "will get nil if it asks for a name that isn't there" do
        # this used to be wonky when we hacked session assignment differently
        config['fo'].should eql(nil)
      end
    end

    context "HOWEVER with the 'value_items' pseudoclass" do

      let :content do
        "foo = bar\nbiff = baz\n[allo]"
      end

      it "you can see its keys like a hash" do
        config.value_items.get_names.should eql %w( foo biff )
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
        config.value_items.each_pair do |k, v|
          k.should eql(ks.pop)
          v.should eql(vs.pop)
        end
      end

      it "you can access its values like a hash (note this returns values not nodes)" do
        config.value_items['foo'].should eql('bar')
      end

      it "accessing values that don't exist will not create bs" do
        config.value_items['baz'].should be_nil
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
  end

  context "As for setting values" do

    before :each do
      tmpdir.prepare
    end

    context "if you start with a config file that doesn't exist" do

      let :path do
        tmpdir.join "my-config.conf"
      end

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
          config.has_name( 'nope' ).should eql false
          config['nope'].should eql(nil)
          config['work'].has_name( 'nope' ).should eql(false)
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
                nerpus = derpus
                times = funner # good times here
            HERE
          end

          it "lets you create a section by assigning a hash to it" do
            config = self.config
            config['goal'] ||= { }
            x = config['goal']
            x.should be_respond_to :get_names
            config['goal']['dream'] = 'deadline'
            _shell = TestLib_::Expect_file_content[].
              shell config.string
            _excerpt_s = _shell.excerpt( 0 .. 4 )
            _excerpt_s.should eql <<-O.unindent
              who = hah
                boo = bah
              [goal]
                dream = deadline
              [play]
            O
          end
        end
      end
    end
  end
end
end
