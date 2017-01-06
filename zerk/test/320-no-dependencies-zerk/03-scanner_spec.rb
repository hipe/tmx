require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] no deps - scanner (all `concat_scanner` for now)" do

    TS_[ self ]
    use :memoizer_methods

    context "when none for first" do

      it "when none for second - empty scanner" do
        _second _the_empty_scanner
        _result.no_unparsed_exists || fail
      end

      it "when some for second - second only" do
        _second _build_non_empty_second
        _result_array == %i( one two ) || fail
      end

      def _first_scanner
        _the_empty_scanner
      end
    end

    context "when some for first" do

      it "when none for second - first only" do
        _second _the_empty_scanner
        _result_array == %i( A B ) || fail
      end

      it "when some for second - both" do
        _second _build_non_empty_second
        _result_array == %i( A B one two ) || fail
      end

      def _first_scanner
        _build_scanner :A, :B
      end
    end

    # -- assertion

    def _result_array
      a = []
      scn = _result
      until scn.no_unparsed_exists
        a.push scn.gets_one
      end
      a
    end

    def _result
      _first = _first_scanner
      _second = remove_instance_variable :@THE_SECOND_SCANNER  # eew
      _result = _first.concat_scanner _second
      _result
    end

    # -- setup

    def _second x
      @THE_SECOND_SCANNER = x
    end

    shared_subject :_the_empty_scanner do
      _scn = _subject_library::Scanner_by.new( & EMPTY_P_ )
      _scn
    end

    def _build_non_empty_second
      _build_scanner :one, :two
    end

    def _build_scanner * sym_a
      _subject_library::Scanner_via_Array.new sym_a
    end

    def _subject_library
      No_deps_zerk_[]
    end
  end
end
