require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] scanner - intro" do

    TS_[ self ]
    use :memoizer_methods

    context "(A, B) (C, D)" do

      it "builds" do
        _builds
      end

      it "ok" do
        _same_A_B_C_D
      end

      shared_subject :_subject do
        _subject_module.define do |o|
          o.add_scanner _build_scanner_with_these( :A, :B )
          o.add_scanner _build_scanner_with_these( :C, :D )
        end
      end
    end

    context "(A, B,) nil, nil, (C, D)" do

      it "builds" do
        _builds
      end

      it "ok" do
        _same_A_B_C_D
      end

      shared_subject :_subject do
        _subject_module.define do |o|
          o.add_scanner _build_scanner_with_these( :A, :B )
          o.add_scanner Home_::THE_EMPTY_SCANNER
          o.add_scanner Home_::THE_EMPTY_SCANNER
          o.add_scanner _build_scanner_with_these( :C, :D )
        end
      end
    end

    # -- assert

    def _same_A_B_C_D
      scn = _subject
      scn.no_unparsed_exists && fail
      scn.gets_one == :A || fail
      scn.no_unparsed_exists && fail
      scn.gets_one == :B || fail
      scn.no_unparsed_exists && fail
      scn.gets_one == :C || fail
      scn.no_unparsed_exists && fail
      scn.gets_one == :D || fail
      scn.no_unparsed_exists || fail
    end

    def _builds
      _subject || fail
    end

    # -- setup

    def _build_scanner_with_these * sym_a
      Home_::Scanner_[ sym_a ]
    end

    def _subject_module
      Home_::Scanner::CompoundScanner
    end
  end
end
