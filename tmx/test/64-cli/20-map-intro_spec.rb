require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - operations (all \"map\" for now)" do

    TS_[ self ]
    use :CLI
    use :non_interactive_CLI_fail_early

    class << self
      alias_method :given_, :given_test_directories
    end  # >>

    context "these three distinct cases have the same error message" do

      it "strange primary" do
        _expect_bad_primary '-strange'
      end

      it "non-primary when primary expected (FOR NOW)" do
        _expect_bad_primary 'beepo'
      end

      it "try to access primary that is blacklisted" do
        _expect_bad_primary '-json-file-stream'
      end

      def _expect_bad_primary same

        invoke _subject_operation, same

        expect_on_stderr "unknown primary: \"#{ same }\""

        _ = '-[a-z]+(?:-[a-z]+)*'

        expect %r(\Aexpecting \{ #{ _ }(?: \| #{ _ }){4,} \}\z)

        expect_failed_normally_
      end
    end

    context "names only, no modifiers" do

      it "works" do
        invoke _subject_operation
        expect_on_stdout 'tyris'
        expect 'deka'
        expect_succeeded
      end

      given_ %w( tyris deka )
    end

    context "select one additional attribute" do

      context "when all values non-nil" do

        it "works as expected (note default record separator is a SPACE)" do
          _invoke_same
          expect_on_stdout "damud 44"
          expect "adder 33"
          expect_succeeded
        end

        given_ %w( damud adder )
      end

      context "when a value is not present" do

        it "displays a DASH for the value" do
          _invoke_same
          expect_on_stdout "frim_frum -"
          expect_succeeded
        end

        given_ %w( frim_frum )
      end

      context "when a value is nil"  # #todo maybe

      def _invoke_same
        invoke _subject_operation, '-select', 'cost'
      end
    end

    it "help about slice" do

      # :#coverpoint-1-D

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

      expect_each_on_stderr_by do |line|
        see[ line ]
        NIL
      end

      expect_succeeded

      if find
        fail "did not find: #{ find.inspect } in #{ count } lines"
      end

      ( 5..10 ).include? count or fail "had this many lines in help screen #{ count }"
    end

    context "slicey dicey" do

      it "works" do
        invoke _subject_operation, '-slice', '2nd', 'half'
        expect_on_stdout 'stern'
        expect 'damud'
        expect 'guld'
        expect_succeeded
      end

      given_ %w( tyris trix stern damud guld )
    end

    def prepare_CLI cli
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
