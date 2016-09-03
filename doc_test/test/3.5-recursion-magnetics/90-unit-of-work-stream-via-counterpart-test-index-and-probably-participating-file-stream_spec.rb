require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] recursion mags - unit of work [..]" do

    TS_[ self ]
    use :memoizer_methods
    use :recursion_stubs

    it "loads" do
      _subject_mag
    end

    context "when the 'list' flag is passed, this request" do

      shared_subject :_units do

        _st = against_ _new_stub_index, __the_asset_stream, :_no_fs_, true
        _st.to_a
      end

      it "produces two units of work" do
        2 == _units.length || fail
      end

      context "first unit" do

        shared_subject :_unit do
          _units.fetch 0
        end

        it "knows asset path" do
          _unit.asset_path == "/stub/asset/file-one" || fail
        end

        it "knows test path" do
          _unit.test_path == "/stub/testdir/file-one_speg.kode" || fail
        end

        it "test path is imaginary"do
          _unit.test_path_is_real && fail
        end
      end

      context "second unit" do

        shared_subject :_unit do
          _units.fetch 1
        end

        it "test path is real"do
          _unit.test_path_is_real || fail
        end
      end

      def __the_asset_stream
        _a = %w( /stub/asset/file-one /stub-asset/file/two )
        Common_::Stream.via_nonsparse_array _a
      end
    end

    context "a minimal normative recursive 'synchronize' operation (mocked)" do

      given_unit_of_work_stream_for_filesystem__ do

        lib = TS_::Recursion_Stubs
        _ro = lib::This_one_read_only_filesystem[]
        lib::MockFilesystem.new _ro
      end

      context "for the first of two units of work" do

        _the_test_file = "/stub/testdir/file-21-participating-create_speg.kode"

        def the_unit_of_work_index_
          0
        end

        it "the emission channel looks this one way" do
          the_emission_.channel_symbol_array == _channel_for( :created ) || fail
        end

        it "the emission content makes sense" do
          _act = the_emission_.expression_line_in_black_and_white
          _exp = /\Acreated «#{ ::Regexp.escape _the_test_file }» \([1-9]\d* lines, [1-9]\d+ bytes\)/
          _act =~ _exp or fail
        end

        it "the content of the created file looks right" do
          _line = find_line_with_ 'My_lib_', _the_test_file
          _line == "      ( My_lib_[ 1 + 1 ] ).should eql 3\n" || fail
        end
      end

      context "for the second of two units of work"
    end

    # -- support for the mutating operation

    def _channel_for sym
      [ :info, :expression, :file_write_summary, sym ]
    end

    # -- support for all sub-operations

    def _new_stub_index
      TS_::Recursion_Stubs::StubIndex.new
    end

    def against_ cti, ppfs, do_list, fs, & any_oes_p
      _subject_mag[ cti, ppfs, do_list, fs, & any_oes_p ]
    end

    def _subject_mag
      Home_::RecursionMagnetics_::UnitOfWorkStream_via_CounterpartTestIndex_and_ProbablyParticipatingFileStream
    end
  end
end
