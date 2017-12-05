require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - operations (all \"map\" for now)" do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI_fail_early
    use :CLI

    class << self
      alias_method :given_, :given_test_directories
    end  # >>

    context "these three distinct cases have the same error message" do

      it "strange primary" do
        _want_bad_primary '-strange'
      end

      it "non-primary when primary expected (FOR NOW)" do
        _want_bad_primary 'beepo'
      end

      it "try to access primary that is blacklisted" do
        _want_bad_primary '-json-file-stream'
      end

      def _want_bad_primary same

        invoke _subject_operation, same

        want_on_stderr "unknown primary \"#{ same }\""

        _ = '-[a-z]+(?:-[a-z]+)*'

        want %r(\Aexpecting \{ #{ _ }(?: \| #{ _ }){4,} \}\z)

        want_failed_normally_
      end
    end

    context "help for subject node" do

      it "usage index builds" do
        _usage_index || fail
      end

      it "usage - head and tail" do
        _ui = _usage_index
        _ui.head == "usage: tmz map " || fail
      end

      these_two = -> h do
        h[ :page_by ] || fail
        h[ :order ] || fail
      end

      it "usage - items - first two primaries are present" do
        _ui = _usage_index
        _h = _ui.item_index
        these_two[ _h ]
      end

      it "description" do
        _line = _sections.description.emissions.first.string
        _line.include? 'produce a stream' or fail
      end

      it "items section - primaries are present" do

        _section = _sections.main_items

        _big_index = _section.to_index_of_common_item_list

        _h = _big_index.item_offset_via_key

        these_two[ _h ]
      end

      # (we don't bother checking for descriptions because
      # the state machine parser requires them presently)

      shared_subject :_usage_index do
        _sections.usage.to_index_of_common_operator_usage_line
      end

      def _sections
        _sections_for_help_screen_normally
      end
    end

    it "help for subject the other way works the same" do

      invoke '-help', _subject_operation
      _actual = _want_common_help_screen_sections
      _expected = _sections_for_help_screen_normally

      diff = _expected.diff_against _actual
      if ! diff.is_the_empty_diff_of_screens
        fail diff.to_exception_message
      end
    end

    shared_subject :_sections_for_help_screen_normally do

      invoke _subject_operation, '-help'
      _want_common_help_screen_sections
    end

    def _want_common_help_screen_sections

        want_common_help_screen_sections_by_ do |sct, o|

          o.want_section "usage" do |sect|
            sct.usage = sect
          end

          o.want_section "description" do |sect|
            sct.description = sect
          end

          o.want_section "primaries" do |sect|  # NOTE the name
            sct.main_items = sect
          end
        end
    end

    context "names only, no modifiers" do

      it "works" do
        invoke _subject_operation
        want_on_stdout 'tyris'
        want 'deka'
        want_succeed
      end

      given_ %w( tyris deka )
    end

    context "select one additional attribute" do

      context "when all values non-nil" do

        it "works as expected (note default record separator is a SPACE)" do
          _invoke_same
          want_on_stdout "damud 44"
          want "adder 33"
          want_succeed
        end

        given_ %w( damud adder )
      end

      context "when a value is not present" do

        it "displays a DASH for the value" do
          _invoke_same
          want_on_stdout "frim_frum -"
          want_succeed
        end

        given_ %w( frim_frum )
      end

      context "when a value is nil"  # #todo maybe

      def _invoke_same
        invoke _subject_operation, '-select', 'cost'
      end
    end

    it "help about slice" do

      # :#coverpoint1.D

      invoke _subject_operation, '-slice', '-help'

      count = 0
      after = -> _ do
        count += 1
      end

      find = "for use under test-directory-oriented operations, is syntactic"
      see = -> line do
        count += 1
        if find == line
          find = nil
          see = after
        end
      end

      want_each_on_stderr_by do |line|
        see[ line ]
        NIL
      end

      want_succeed

      if find
        fail "did not find: #{ find.inspect } in #{ count } lines"
      end

      ( 5..10 ).include? count or fail "had this many lines in help screen #{ count }"
    end

    context "slicey dicey" do

      it "works" do
        invoke _subject_operation, '-slice', '2nd', 'half'
        want_on_stdout 'stern'
        want 'damud'
        want 'guld'
        want_succeed
      end

      given_ %w( tyris trix stern damud guld )
    end

    def prepare_subject_CLI_invocation cli
      cli.json_file_stream_by { X_c_op_explosive_stream[] }
      NIL
    end

    map = 'map'
    define_method :_subject_operation do
      map
    end

    # ==

    X_c_op_explosive_stream = Lazy_.call do
      Common_.stream do
        TS_._EXPLICITLY_EXPECTING_NOT_TO_GET_TO_THE_POINT_OF_LISTING_JSON_FILES
      end
    end

    # ==
  end
end
# #tombstone: (probably not interesting) ancient [br] reactive model tests
