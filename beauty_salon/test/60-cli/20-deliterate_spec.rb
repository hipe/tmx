# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] CLI - deliterate" do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI
    use :my_CLI

    same = %w( deliterate )

    context '0) no args' do  # :COVERPOINT2.1:[br]

      given do
        argv( * same )
      end

      it 'line 1 - NOTE no [#br-002.5] yet - every parameter is a primary for now' do
        _actual = first_line_string
        _actual == %(missing required primaries "-from-line", "-to-line" and "-file"\n) || fail
      end

      it 'line 2 - invite' do
        _want_deep_invite second_and_final_line_string
      end

      it 'fails' do
        _want_exitstatus_for_failure
      end
    end

    context '1.2) -x' do

      given do
        argv( * same, '-x' )
      end

      it 'first line - whine' do
        first_line_string == %(unrecognized primary "-x"\n) || fail
      end

      context 'second line' do

        it 'looks like splay' do
          _tuple || fail
        end

        it 'talkin about the *injected* associations' do
          _actual_s_a = _tuple
          _expected_s_a = %w(
            -file
            -help
            -to-line
          )
          _actual_s_a == _expected_s_a || fail
        end

        shared_subject :_tuple do
          _actual = second_line_string
          oxford_split_or_ _actual, 'did you mean ','?'
        end
      end

      it 'third line - DEEPER invite' do
        _actual = third_and_final_line_string
        _want_deep_invite _actual
      end

      it 'fails' do
        _want_exitstatus_for_failure
      end
    end

    context '1.4) -h' do

      given do
        argv 'deliterate', '-h'
      end

      it 'usage line - constituents (subject to change)' do

        _sect = _sections.fetch :usage
        idx = _sect.to_index_of_common_operator_usage_line

        idx.head == "usage: chimmy deliterate " || fail

        idx.had_ellipsis || fail

        idx.item_index.keys == %i( from_line to_line file ) || fail
      end

      it 'long (long!) description' do

        _sect = _sections.fetch :description
        ( 30 .. 40 ).include? _sect.number_of_lines or fail
      end

      it 'items - constituency' do

        _index = _items_index
        _actual = _index.to_keys_set
        _actual == ::Set.new( %i( file from_line help to_line ) ) || fail
      end

      it 'items - description with one line' do

        _actual = _items_index.dereference( :file ).description_line_array
        want_these_lines_in_array_ _actual do |y|
          y << 'a file with code in it'
        end
      end

      it 'NOTE for now every item is a primary, even required while #open [#br-002.5])' do

        _guy = _items_index.dereference :file
        _guy.label == '-file' || fail
      end

      shared_subject :_items_index do

        _sect = _sections.fetch :primaries
        _these = _sect.to_index_of_common_item_list_EXPERIMENTAL_ALTERNATIVE
        _these  # hi. #todo
      end

      shared_subject :_sections do
        parse_help_screen_sections_ :usage, :description, :primaries
      end

      it 'succeeds' do
        _want_exitstatus_for_success
      end
    end

    context 'missing required' do

      given do
        argv( * same )
      end

      it 'line 1 whines(#open [#br-002.5] will change this)' do
        _hi = first_line_string
        _s_a = oxford_split_and_ _hi, 'missing required primaries '
        require 'set'  # ..
        _actual = _s_a.to_set
        _expected = %w( "-file" "-to-line" "-from-line" ).to_set
        _actual == _expected || fail
      end

      it 'line 2 - deep invite' do
        _want_deep_invite second_and_final_line_string
      end

      it 'failed' do
        _want_exitstatus_for_failure
      end
    end

    context 'integer not integer'

    context 'file not found' do

      given do
        _path = TestSupport_::Fixtures.file :not_here
        if false  # while #open [#br-002.5]
        argv( * same, '1', '2', _path )
        end
        argv( * same,
          '-from-line', '1',
          '-to-line', '2',
          '-file', _path,
        )
      end

      it 'first line - styled whine (#open [#br-002.5])' do
        _actual = unstyle_styled_ first_line_string
        _actual =~ %r(\ANo such «file» - [[:graph:]]+$) || fail
      end

      it 'second line - invite' do
        _want_deep_invite second_and_final_line_string
      end

      it 'failed' do
        _want_exitstatus_for_failure
      end

      def CLI_options_for_want_stdout_stderr
        X_cdelit_this_CLI_setup
      end
    end

    context 'money' do

      given do

        _path = Fixture_file_[ '01-some-code.code' ]

        if false  # while #open [#br-002.5]
        argv( * same, '3', '3', _path )
        end
        argv( * same,
          '-from-line', '3',
          '-to-line', '5',
          '-file', _path,
        )
      end

      it 'the STDOUT lines are the code lines only' do

        _actual = _tuple.first

        want_these_lines_in_array_ _actual do |y|
          y << "    def normalize_range\n"
          y << NEWLINE_
          y << "      if @to_line < @from_line\n"
        end
      end

      it 'the STDERR lines are the comment lines only' do

        _actual = _tuple.last

        want_these_lines_in_array_ _actual do |y|
          y << "for example, you could deliterate these lines.\n"
        end
      end

      it 'succeeded' do
        _want_exitstatus_for_success
      end

      shared_subject :_tuple do
        partition_expressed_lines_into_output_lines_and_errput_lines_
      end

      def CLI_options_for_want_stdout_stderr
        X_cdelit_this_CLI_setup
      end
    end

    # ==

    def _want_deep_invite line
      line == "try 'chimmy deliterate -h'\n" || fail
    end

    def _want_exitstatus_for_failure
      exitstatus.zero? && fail
    end

    def _want_exitstatus_for_success
      exitstatus.zero? || fail
    end

    # ==

    X_cdelit_this_CLI_setup = -> cli do

      cli.expression_agent_by = -> do
        self._NEVER
        TS_::My_CLI::Legacy_expag_instance[]
      end

      cli.filesystem = ::File
    end

    # ==
    # ==
  end
end
# #history-A.1: full rewrite when weaning off [br] matryoshka
#   (can-be-temporary): erasing code that covered the more desirable magic of
#   [#br-002.5]. we'll bring it back.)
