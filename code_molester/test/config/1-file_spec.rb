require_relative '../test-support'

module Skylab::CodeMolester::TestSupport

  # <-

describe "[cm] config file" do

  TS_[ self ]
  use :tmpdir
  use :config_file

  context "generic empty config file" do

    share_subject :file do
      build_config_file_
    end

    it "builds" do
      file
    end

    it "responds to valid?" do
      file.should be_respond_to :valid?
    end

    it "responds to invalid_reason" do
      file.should be_respond_to :invalid_reason
    end
  end

  def input_string
    NIL_
  end

  dangerous_memoize :path do
    tmpdir.join 'whatever'
  end

  context "with regards to validity/parsing" do

    context "out of the box" do

      share_file_as_subject_

      it "is valid (because an empty file is)" do
        subject.valid?.should eql(true)
      end

      it "has no content items" do
        subject.content_items.length.should be_zero
      end

      it "converting it to a string give you the empty string" do
        subject.string.should eql EMPTY_S_
      end
    end

    context "when input is bunch of blank lines" do

      share_file_as_subject_

      it "it is valid" do
        subject_invalid_reason_is_nil_
      end

      it "has no content items" do
        subject_has_no_content_items_
      end

      it "unparses losslessly" do
        unparses_losslessly_
      end

      memoize :input_string do
        "\n  \n\t\n"
      end
    end

    context "when input is one comment" do

      share_file_as_subject_

      it "it is valid" do
        subject_invalid_reason_is_nil_
      end

      it "has no content items" do
        subject_has_no_content_items_
      end

      it "unparses losslessly" do
        unparses_losslessly_
      end

      memoize :input_string do
        "      # ha-blah"
      end
    end

    context "when input is one assigmnent line" do

      def _parses_as_one_assignment_line

        _parses_as_one_content_item
        _line.symbol_i.should eql :assignment_line
      end

      def _unparses_value_as_empty_string
        value.should eql EMPTY_S_
      end

      def name
        _line.child( :name ).last
      end

      def value
        _line.child( :value ).last
      end

      def comment
        _line.child( :comment ).child( :body ).unparse
      end

      def _line
        subject.content_items.first
      end

      context "as the minimal normative case" do

        share_file_as_subject_

        it "parses as one assignment line" do
          _parses_as_one_assignment_line
        end

        it "unparses name" do
          name.should eql('foo')
        end

        it "unparses value" do
          value.should eql('bar')
        end

        def input_string
          'foo=bar'
        end
      end

      context("that has spaces and a comment") do

        share_file_as_subject_

        it "parses as one assignment line" do
          _parses_as_one_assignment_line
        end

        it "unparses name" do
          name.should eql('foo')
        end

        it "unparses value" do
          value.should eql('bar baz')
        end

        it "unparses comment!" do
          comment.should eql('boffo')
        end

        def input_string
          "  foo= bar baz #boffo"
        end
      end

      context("that has no value at all") do

        share_file_as_subject_

        it "parses as one assignment line" do
          _parses_as_one_assignment_line
        end

        it "unprases name" do
          name.should eql('foo_bar')
        end

        it "unparses value as empty string" do
          _unparses_value_as_empty_string
        end

        def input_string
          "\t  foo_bar  ="
        end
      end

      context("that has no value, but trailing whitespace") do

        share_file_as_subject_

        it "parses as one assignment line" do
          _parses_as_one_assignment_line
        end

        it "unparses name" do
          name.should eql('fooBar09')
        end

        it "unparses value as empty string" do
          _unparses_value_as_empty_string
        end

        it "unparses comment" do
          comment.should eql("some comment\t ")
        end

        def input_string
          " fooBar09   = \t#some comment\t "
        end
      end
    end # assignment line

    def _parses_as_one_content_item

      subject_invalid_reason_is_nil_

      subject.content_items.length.should eql 1
    end

    context "when input is a valid section line" do

      context "in the ideal, general case" do

        share_file_as_subject_

        it "parses as one section" do
          _parses_as_one_section
        end

        it "unparses section name" do
          section_name_node.should eql('foo')
        end

        def input_string
          "[foo]"
        end
      end

      context "with lots of spaces and tabs everywhere" do

        share_file_as_subject_

        it "parses as one section" do
          _parses_as_one_section
        end

        it "unparses section name (NOTE trailing WS preserved)" do
          section_name_node.should eql('09foo.bar ') # (per the grammar .. but meh idc)
        end

        def input_string
          "  \t [\t 09foo.bar ]   \t"
        end
      end

      def _parses_as_one_section
        _parses_as_one_content_item
        subject.content_items.first.symbol_i.should eql :section
      end

      def section_name_node
        _sect.child( :header ).child( :section_line ).child( :name ).last
      end

      def _sect
        subject.content_items.first
      end
    end
  end

  context "With regards to rendering parse errors" do

    def _subject_is_invalid
      subject.valid?.should eql(false)
    end

    def invalid_reason
      subject.invalid_reason.to_s
    end

    context "if you had an invalid section name on e.g. the third line" do

      share_file_as_subject_

      it "file is invalid" do
        _subject_is_invalid
      end

      it "it will report line number and context and expecting" do
        invalid_reason.should match(
          %r{^expecting.+in line 3 at the end of "\[foo/bar\]\]"}i )
      end

      def input_string
        "foo=bar\n#ok\n[foo/bar]]\n# one more line"
      end
    end

    context "if you had something invalid at the very first character" do

      share_file_as_subject_

      it "file is invalid" do
        _subject_is_invalid
      end

      it "will do the same as above" do
        invalid_reason.should eql(
          'Expecting "#", "\n" or "[" at the beginning of line 1' )
      end

      def input_string
        '{'
      end
    end

    context "if you had something invalid as the very last character" do

      share_file_as_subject_

      it "file is invalid" do
        _subject_is_invalid
      end

      it "will do the same as above" do
        invalid_reason.should eql(
          'Expecting "#", "\n" or "[" in line 4 at the end of "  }"' )
      end

      def input_string
        "\n\n# foo\n  }"
      end
    end
  end

  context "As for getting values" do

    context "with a file with one value" do

      share_file_as_config_

      def input_string
        'foo = bar'
      end

      it "can get it" do
        config['foo'].should eql('bar')
      end

      it "using a symbol for a key throws, does not convert" do

        _rx = /\Ano implicit conversion of 'foo' into String\b/

        cfg = config

        begin
          cfg[ :foo ]
        rescue ::TypeError => e
        end

        e.message.should match _rx
      end

      it "will get nil if it asks for a name that isn't there" do
        # this used to be wonky when we hacked session assignment differently
        config['fo'].should eql(nil)
      end
    end

    context "HOWEVER with the 'value_items' pseudoclass" do

      share_file_as_config_

      memoize :input_string do
        "foo = bar\nbiff = baz\n[allo]".freeze
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

      context "you can alter an existing value" do

        share_file_as_config_ do | cfg |

          cfg.value_items[ 'foo' ] = 'blamo'
          NIL_
        end

        it "the assignment does not raise" do
          config
        end

        it "retreive the value thru `value_items`" do
          config.value_items['foo'].should eql('blamo')
        end

        it "unparsing looks OK" do
          config.string.split("\n").first.should eql("foo = blamo")
        end
      end

      context "you can create new values" do

        share_file_as_config_ do | cfg |

          cfg[ 'bleuth' ] = 'michael'
          NIL_
        end

        it "the assignment does not raise" do
          config
        end

        it "unparsing looks OK" do

          _exp = <<-HERE.unindent.strip
            foo = bar
            biff = baz
            bleuth = michael
            [allo]
          HERE

          config.string.should eql _exp
        end
      end
    end
  end

  context "As for setting values" do

    context "if you start with a config file that doesn't exist" do

      share_file_as_config_

      def path
        TestSupport_::Fixtures.file :not_here
      end

      def _is_valid
        config.should be_valid
      end

      def _does_not_exist
        config.exist?.should eql false
      end

      def _unparses_as_empty_string
        config.string.should eql EMPTY_S_
      end

      it "it knows it doesn't exist" do
        _does_not_exist
      end

      it "it considers itself valid" do
        _is_valid
      end

      it "it unparses as the empty string" do
        _unparses_as_empty_string
      end

      it "produces a parse tree anyway (with three nodes!?)" do
        config.sexp.length.should eql 3
      end

      context "if you build the instance with a chunky string of content" do

        # (note that the below happens even though the file is not written yet)

        share_file_as_config_

        memoize :input_string do

          <<-HERE.unindent.freeze
            who = hah
              boo = bah
            [play]
              times = fun
            [work]
              times = funner # good times here
          HERE
        end

        it "access that value that is indented but at top level" do
          config['boo'].should eql('bah')
        end

        it "access the value one level deep on line with a comment" do
          config['work']['times'].should eql('funner')
        end

        it "access the value one level deep on a line with no comment" do
          config['play']['times'].should eql('fun')
        end

        it "ask it if it has a non-existent toplevel node, it doesn't" do
          config.has_name( 'nope' ).should eql false
        end

        it "request a topevel node that doesn't exist, value is nil" do
          config['nope'].should eql(nil)
        end

        it "ask it if it has a non-existent 2nd level node, it doesn't" do
          config['work'].has_name( 'nope' ).should eql(false)
        end

        it "request a 2nd level node that doesn't exist, value is nil" do
          config['work']['nope'].should eql(nil)
        end

        context "lets you add new values" do

          # the below tests do NOT share a config file!

          def path
            NIL_
          end

          it "to the root node (note the inherited whitespace)" do

            config = build_config_file_

            config['new_item'] = 'new value'

            config.string.split("\n")[0,3].join("\n").should eql(<<-HERE.unindent.strip)
              who = hah
                boo = bah
                new_item = new value
            HERE
          end

          it "to existing child nodes (note the unparsing of one section only!)" do

            config = build_config_file_

            config['work']['nerpus'] = 'derpus'

            config['work'].unparse.strip.should eql(<<-HERE.unindent.strip)
              [work]
                nerpus = derpus
                times = funner # good times here
            HERE
          end

          it "lets you create a section by assigning a hash to it" do

            config = build_config_file_

            config['goal'] ||= { }

            x = config['goal']
            x.should be_respond_to :get_names

            config['goal']['dream'] = 'deadline'

            _shell = TestLib_::Expect_line[].shell config.string
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
# ->
end
