require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] recursion mags - unit of work [..]" do

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      _subject_mag
    end

    context "runny money" do

      shared_subject :_units do
        _st = _subject_mag[ __build_stub_index, __build_stub_stream ]
        _st.to_a
      end

      it "two units of work" do
        2 == _units.length || fail
      end

      context "first unit" do

        shared_subject :_unit do
          _units.fetch 0
        end

        it "knows asset path" do
          _ = _unit.asset_path
          _ == "/stub/asset/file-one" || fail
        end

        it "knows test path" do
          _ = _unit.test_path
          _ == "/stub/testdir/file-one_speg.kode" || fail
        end

        it "imagniary"do
          _unit.test_path_is_real && fail
        end
      end

      context "second unit unit" do

        shared_subject :_unit do
          _units.fetch 1
        end

        it "real"do
          _unit.test_path_is_real || fail
        end
      end
    end

    def __build_stub_stream
      _a = %w( /stub/asset/file-one /stub-asset/file/two )
      Common_::Stream.via_nonsparse_array _a
    end

    def __build_stub_index
      _StubIndex.new
    end

    dangerous_memoize :_StubIndex do
      __LookupResult
      class X_rm_uowst_StubIndex

        def initialize
          @is_real = false
        end

        def details_via_asset_path ast
          b = @is_real
          @is_real = ! b
          _path = "/stub/testdir/#{ ::File.basename( ast ) }_speg.kode"
          X_rm_uowst_LookupResult.new b, _path
        end
        self
      end
    end

    dangerous_memoize :__LookupResult do
      X_rm_uowst_LookupResult = ::Struct.new(
        :is_real,
        :to_path,
      ) do
        # ..
      end
    end

    def _subject_mag
      Home_::RecursionMagnetics_::UnitOfWorkStream_via_CounterpartTestIndex_and_ProbablyParticipatingFileStream
    end
  end
end
