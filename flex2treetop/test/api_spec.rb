require_relative 'my-test-support'

module Skylab::Flex2Treetop::MyTestSupport

  describe "[f2] API" do

    extend Top_TS_

    use :expect_event
    use :expect_line

      it "load" do

        Home_::API
      end

      it "ping" do

        call_API :ping, :arg_1, :_x_

        expect_neutral_event :ping, 'helo:(_x_)'
        expect_no_more_events
        @result.should eql :_cheeky_monkey_
      end

      it "u-nrecognized action" do

        call_API :wiggle, :you_never, :see_these, :args

        expect_not_OK_event :no_such_action do  | ev |

          ev.action_name.should eql :wiggle
        end
        expect_failed
      end

      it "version" do

        call_API :version

        @result.should match(
          %r(\A#{ ::Regexp.escape REAL_PROGNAME_ }: \d+(?:\.\d+)*\z) )
      end

      it "bare version" do

        call_API :version, :bare

        @result.should match %r(\A\d+(?:\.\d+)*\z)
      end

      it "reflect tests" do

        call_API :test, :list
        st = @result
        test = st.gets
        test.basename_string.should eql 'fixthis.flex'
      end

      it "infile not exist" do

        call_API :translate,
          :flex_file, tmpdir.join( 'not-there.flex' ).to_path,
          :resources, Mock_resources_[],
          * _outpath_arg( '_no_see_' )

        expect_not_OK_event_ :errno_enoent,
          %r(\bNo such \(par flex_file\) - \(pth ".+not-there\.flex"\)\z)

        expect_failed
      end

      it "infile not file" do

        call_API :translate,
          :flex_file, FIXTURE_FILES_DIR_,
          :resources, Mock_resources_[],
          * _outpath_arg( '_meh_' )

        em = expect_not_OK_event :wrong_ftype

        black_and_white( em.cached_event_value ).should match(
          %r(\A«[^»]+/fixture-files» exists but is not a file, it is a directory\b) )

        expect_failed
      end

      it "infile exist, outfile exist and force not present" do

        call_API :translate, * _etc( _file_with_some_content )

        _em = expect_not_OK_event_ :missing_required_permission

        black_and_white( _em.cached_event_value ).should match(
          %r(\A'output-path' exists, won't overwrite without 'force': #{
            }«[^»]+file-with-some-content) )

        expect_failed
      end

      it "infile exist, outfile not file" do

        _in_path = _file_with_some_content

        _out_path = FIXTURE_FILES_DIR_

        call_API :translate, :force, :flex_file, _in_path, * _etc( _out_path )

        _em = expect_not_OK_event_ :errno_eisdir

        _rx = %r(\AIs a directory - «.+/fixture-files)

        black_and_white( _em.cached_event_value ).should match _rx

        expect_failed
      end

      it "minimal case" do

        _init_outpath

        call_API :translate, * _etc

        _prepare_to_verify_content

        __expect_first_few_lines

        __expect_last_few_lines
      end

      def __expect_first_few_lines

        next_line.should match %r(\A# Autogenerated by flex2tree)

        _skip_blanks_and_comments

        line.should eql "rule escape__of_lexer__\n"
      end

      def __expect_last_few_lines

        scn = @expect_line_scanner

        exp_a = <<-'HERE'.unindent.split %r((?<=\n))
          rule ignore_comments
            "\/" "\*" [^*]* "\*"+ ([^/*] [^*]* "\*"+)* "\/"
          end
        HERE

        scn.advance_to_before_Nth_last_line exp_a.length

        exp_a.each do | expect_line |

          scn.next_line.should eql expect_line
        end
      end

      it "wrap in one grammar module" do

        _init_outpath

        call_API :translate, :wrap_in_grammar, "Danbury", * _etc

        _prepare_to_verify_content

        _skip_blanks_and_comments

        line.should eql "grammar Danbury\n"

        _count = @expect_line_scanner.skip_lines_that_match(

          /\A[ ]{2,}[^[:space:]]|\A\n\z/ )

        _count.should eql 20

        line.should eql "end\n"
      end

      it "wrap in two grammar modules" do

        _init_outpath

        call_API :translate, :wrap_in_grammar, "Fibble::Toppel", * _etc

        _prepare_to_verify_content

        _skip_blanks_and_comments

        line.should eql "module Fibble\n"
        next_line.should eql "  grammar Toppel\n"
        next_line.should eql NEWLINE_
        next_line.should eql "    # from flex name definitions\n"
      end

      def _prepare_to_verify_content

        :translated == @result or fail

        expect_neutral_event :before_probably_creating_new_file
        expect_neutral_event :cant_deduce_rule
        expect_no_more_events

        @output_s = ::File.read @outpath
        NIL_
      end

      it "bad grammar name" do

        _init_outpath

        call_API :translate, :wrap_in_grammar, 'Doonesbury Cartoon', * _etc

        :translate_failure == @result or fail

        expect_neutral_event :before_probably_creating_new_file

        _em = expect_not_OK_event :invalid_NS

        black_and_white( _em.cached_event_value ).should eql(

          "grammar namespaces look like \"Foo::BarBaz\". #{
            }this is not a valid grammar namespace: \"Doonesbury Cartoon\"" )

        expect_no_more_events

        ::File.read( @outpath ).should match( /\A# Auto[^\n]+\n\z/ )
      end

      it "option - show sexp (it's a big dump)" do

        g = TestSupport_::IO.spy.group.new

        g.do_debug_proc = -> do
          do_debug
        end

        g.debug_IO = debug_IO
        io = g.add_stream :A

        @resources = Mock_Resources_.new nil, nil, io

        _init_outpath  # we will assert that it is not created

        call_API :translate, :show_sexp_only, * _etc

        :showed_sexp == @result or fail

        ::File.exist?( @outpath ) and fail

        @line_stream_for_expect_line = g.flush_to_line_stream_on :A

        next_line.should eql "[:file,\n"

        scn = @expect_line_scanner

        _count = scn.skip_until_before_Nth_last_line 1
        _count.should eql 59

        scn.next_line.should match(

          %r(\A {2,} :action=>\[:action, "return \*yytext;) )

        scn.next_line.should be_nil
      end

      it "parser from FS - nosaj thing - x" do

        _init_outpath  # we will assert that it is not created

        _path = ::File.join FIXTURE_FILES_DIR_, 'not-a-dir'

        _API_invoke_with_parser_dir _path

        :parser_dir_not_exist == @result or fail

        ::File.exist?( @outpath ) and fail

        expect_not_OK_event :enoent,
          %r(\ANo such file or directory #{ ICK_ }- [^ ]+/not-a-dir\z)

        expect_no_more_events
      end

      it "parser from FS - saj thing - OK", alone: true do

        # NOTE - sadly this is not a test-friendly scenario: the designed
        # behavior is different based on whether or not grammars have been
        # loaded already. as such, the below conditionally covers whether
        # this test is run alone (or perhaps first), and whether it is run
        # after cases that will have loaded the gramars already.

        _init_outpath  # we will assert that it is not created

        _path = tmpdir.touch_r( 'a-dir/' ).to_path

        _API_invoke_with_parser_dir _path

        expect_neutral_event :wrote_grammar
        expect_neutral_event :writing_compiled
        expect_neutral_event :wrote_compiled

        if :filesystem_touched == @result
          __single_case
        else
          __group_case
        end

        expect_no_more_events
      end

      def __single_case

        expect_neutral_event :touched
      end

      def __group_case

        :cannot_use_FS_flex_file_parser_already_loaded == @result or fail
        expect_not_OK_event :ff_parser_already
      end

      def _API_invoke_with_parser_dir x

        call_API :translate,

          :use_FS_parser, :FS_parser_dir, x, :endpoint_is_FS_parser, * _etc
      end

      def _etc x=@outpath
        [ :resources, ( resources || Mock_resources_[] ),
          :flex_file, fixture_flex_( :mini ),
          :output_path, x ]
      end

      attr_reader :resources

      def _outpath_arg s
        [ :output_path, s ]
      end

      def _file_with_some_content

        fixture_file_ 'file-with-some-content', :txt
      end

      def _init_outpath

        tmpdir = self.tmpdir
        tmpdir.prepare  # nuke any old files from before
        @outpath = tmpdir.join( 'o.rb' ).to_path
        NIL_
      end

      def _skip_blanks_and_comments

        expect_line_scanner.advance_past_lines_that_match %r(\A(?:#|$))

        NIL_
      end

      def subject_API
        Home_::API
      end
  end
end
