# frozen_string_literal: true
require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] CLI - wrap (introduces some stack depth)' do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI
    use :my_CLI

    dig = %w( text wrap ).freeze
    help = '-h'

    context '1.3) end on a branch' do

      given do
        no_stdin_or_filesystem
        argv dig.first
      end

      it 'first line splays' do
        _actual = first_line_string
        _actual == "available operators and primaries: wrap and -help\n" || fail
      end

      it 'second and final line invites to branch' do
        _actual = second_and_final_line_string
        _actual == "try 'chimmy text -h'\n" || fail
      end
    end

    context '2.4) help on the branch' do

      given do
        no_stdin_or_filesystem
        argv dig.first, help
      end

      this_one_set = Lazy_.call do
        %i(
          wrap
        ).to_set
      end

      it 'usage' do

        _sect = _sections.fetch :usage
        idx = _sect.to_index_of_common_branch_usage_line

        idx.head == "usage: chimmy #{ dig.first } " || fail
        idx.mid == dig.last || fail
        idx.tail == " [opts]\n" || fail

        require 'set'
        idx.item_index.keys.to_set == this_one_set[] || fail
      end

      it 'description' do

        _sect = _sections.fetch :description
        _sect.emissions[0].string.include? 'text-related actions' or fail  # (generated text by [br])
      end

      it 'operations constituency' do

        _index = _items_index
        _index.to_keys_set == this_one_set[] || fail
      end

      it 'operations description' do

        _item = _items_index.dereference :wrap

        3 <= _item.description_line_array.length || fail
      end

      shared_subject :_items_index do

        _sect = _sections.fetch :operations
        _these = _sect.to_index_of_common_item_list_EXPERIMENTAL_ALTERNATIVE
        _these  # hi. #todo
      end

      shared_subject :_sections do
        parse_help_screen_sections_ :usage, :description, :operations
      end
    end

    context '3.4) help on the endpoint' do

      given do
        no_stdin_or_filesystem
        argv( * dig, help )
      end

      it 'usage' do

        _sect = _sections.fetch :usage
        idx = _sect.to_index_of_common_operator_usage_line
        idx || fail

        idx.head == "usage: chimmy #{ dig.join ' ' } " || fail

        idx.had_ellipsis || fail

        idx.item_index.keys == %i( lines num_chars_wide preview ) || fail
      end

      it 'description (all lines)' do

        _sect = _sections.fetch :description
        ( 5 .. 15 ).include? _sect.number_of_lines or fail
      end

      it 'primaries (partial constutiency)' do

        _index = _items_index
        _actual = _index.to_keys_set
        _expected_subset = %i( num_chars_wide preview help ).to_set
        _expected_subset < _actual || fail
      end

      it 'num chars wide default shows up here LOOK needs that one thing' do

        _actual = _items_index.dereference( :num_chars_wide ).description_line_array

        expect_these_lines_in_array_ _actual do |y|
          y << "how wide can the longest line be? (default: 80)"
        end
      end

      shared_subject :_items_index do

        _sect = _sections.fetch :primaries
        _these = _sect.to_index_of_common_item_list_EXPERIMENTAL_ALTERNATIVE
        _these  # hi. #todo
      end

      shared_subject :_sections do
        parse_help_screen_sections_ :usage, :description, :primaries
      end
    end

    context 'not both' do

      given do
        noninteractive_stdin
        argv( * dig, '-upstream', 'xx' )
      end

      it 'whines' do
        expect_failure_message_ %r(\Aambiguous upstream arguments - canno)
      end

      it 'fails' do
        fails
      end
    end

    context 'via a file' do

      given do

        interactive_stdin

        argv( * dig,
          '-num-chars-wide', '14',
          '-verbose',
          '-upstream', _this_one_good_path,
        )
      end

      it 'output lines are wrapped (one line, 47 chars wide became..)' do
        _actual = _tuple.first.map { |line| line.length }
        _actual == [ 12, 14, 6, 11, 5 ] || fail
      end

      it 'errput lines are talkin bout that revolution' do
        _actual = _tuple.last
        expect_these_lines_in_array_ _actual do |y|
          y << "(line range union: 1-INFINITY)\n"
        end
      end

      shared_subject :_tuple do
        partition_expressed_lines_into_output_lines_and_errput_lines_
      end

      it 'succeeds' do
        succeeds
      end
    end

    context 'via STDIN' do

      given do

        stdin _stdin_mocks.noninteractive_STDIN_class.via_lines( [
          "one two\n",
          "three four\n",
        ] )

        argv( * dig,
          '-num-chars', '5',
          '-upstream', '-'
        )
      end

      it 'output lines are wrapped (no errput)' do
        _st = to_output_line_stream_strictly
        _actual = _st.map_by {|s| s.chomp!; s}.to_a
        _actual == %w( one two three four ) || fail
      end

      it 'succeeds' do
        succeeds
      end
    end

    context 'ambiguous primaries (COVERS [fi])' do  # :COVERPOINT2.3:[fi]

      it 'whines' do

        _actual = first_line_string.split ' - '

        expect_these_lines_in_array_ _actual do |y|
          y << 'ambiguous attribute "-num"'
          y << %(did you mean "num-chars-wide" or "number-the-lines"?\n)
        end

        _expect_same_invite
      end

      it 'fails' do
        fails
      end

      given do
        interactive_stdin
        argv( * dig, '-num' )
      end
    end

    it "[tmx] integration (stowaway)", TMX_CLI_integration: true do

      Home_::Autoloader_.require_sidesystem :TMX

      cli = ::Skylab::TMX.test_support.begin_CLI_expectation_client

      cli.invoke 'beauty-salon', 'ping'

      cli.on_stream :serr

      cli.expect_line_by do |line|
        _unstyled = cli.unstyle_styled line
        _unstyled == "[bs] says hello" || fail
      end

      cli.expect_on_stdout 'hello_from_beauty_salon'

      cli.expect_succeed_under self
    end

    # -- assertion assistance

    def expect_failure_message_ x

      _actual = first_line_string
      if x.respond_to? :ascii_only?
        _actual == x || fail
      else
        _actual =~ x || fail
      end
      _expect_same_invite
    end

    def _expect_same_invite
      _actual = second_and_final_line_string
      _actual == "try 'chimmy text wrap -h'\n" || fail
    end

    # -- setup

    def _this_one_good_path
      TestSupport_::Fixtures.file :one_line
    end

    def no_stdin_or_filesystem
      stdin nil
      no_filesystem
    end

    def interactive_stdin
      stdin _stdin_mocks.interactive_STDIN_instance
    end

    def noninteractive_stdin
      stdin _stdin_mocks.noninteractive_STDIN_instance
    end

    def stdin x
      @STDIN = x
    end

    def _stdin_mocks
      Home_.lib_.system.test_support::STUBS
    end

    # -- hook-in

    # ~

    def CLI_options_for_expect_stdout_stderr
      if self.NO_FILESYSTEM
        NOTHING_
      else
        X_textwrap_this_CLI_setup
      end
    end

    def no_filesystem
      @NO_FILESYSTEM = true
    end

    attr_reader :NO_FILESYSTEM

    # ~

    def stdin_for_expect_stdout_stderr
      @STDIN
    end

    X_textwrap_this_CLI_setup = -> cli do
      cli.filesystem = ::File
    end

    # ==
    # ==
  end
end
# #history-A.1: rewrite for matryoshka wean (#tombstone lemma)
