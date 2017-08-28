require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] CLI - deliterate" do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI
    use :my_CLI

    same = %w( deliterate )

    context '0) no args' do  # :#[br]:COVERPOINT2.1

      given do
        argv( * same )
      end

      it 'line 1 - NOTE no [#br-002.5] yet - every parameter is a primary for now' do
        _actual = first_line_string
        _actual == %(missing required primaries "-from-line", "-to-line" and "-file"\n) || fail
      end

      it 'line 2 - invite' do
        _expect_deep_invite second_and_final_line_string
      end

      it 'fails' do
        _expect_exitstatus_for_failure
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
          md0 = %r(\Adid you mean (?<rest>[-, a-z]+)\?$).match _actual
          md0 || fail
          md1 = %r([ ]or[ ]).match md0[ :rest ]
          md1 || fail
          s_a = md1.pre_match.split ', '
          s_a.push md1.post_match
          s_a
        end
      end

      it 'third line - DEEPER invite' do
        _actual = third_and_final_line_string
        _expect_deep_invite _actual
      end

      it 'fails' do
        _expect_exitstatus_for_failure
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
        expect_these_lines_in_array_ _actual do |y|
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
        h = {}
        parse_help_screen_fail_early_ do |o|

          o.expect_section 'usage' do |sect|
            h[ :usage ] = sect
          end

          o.expect_section 'description' do |sect|
            h[ :description ] = sect
          end

          o.expect_section 'primaries' do |sect|
            h[ :primaries ] = sect
          end
        end
        h.freeze
      end

      it 'succeeds' do
        _expect_exitstatus_for_success
      end
    end

    $stderr.puts "2 TESTS COMMENTED OUT in [bs]"
    if false
    it "no ent" do

      _path = TestSupport_::Fixtures.file( :not_here )

      invoke 'deliterate', '1', '2', _path

      expect :styled, :e, /\Afailed because no such <file> - /
      expect_specifically_invited_to :deliterate
    end

    it "money" do

      _path = Fixture_file_[ '01-some-code.code' ]

      invoke 'deliterate', '3', '5', _path

      expect :o, "    def normalize_range"
      expect :o, EMPTY_S_
      expect :o, "      if @to_line < @from_line"
      expect :e, "for example, you could deliterate these lines."
      expect_succeed
    end
    end

    # ==

    def _expect_deep_invite line
      line == "try 'chimmy deliterate -h'\n" || fail
    end

    def _expect_exitstatus_for_failure
      exitstatus.zero? && fail
    end

    def _expect_exitstatus_for_success
      exitstatus.zero? || fail
    end

    # ==
    # ==
  end
end
# #history-A.1: full rewrite when weaning off [br] matryoshka
#   (can-be-temporary): erasing code that covered the more desirable magic of
#   [#br-002.5]. we'll bring it back.)
