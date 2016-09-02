require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] recursion mags - unit of work [..]" do

    TS_[ self ]
    use :memoizer_methods
    use :recursion_stubs

    it "loads" do
      _subject_mag
    end

    context "for listing" do

      shared_subject :_units do

        _st = _against _new_stub_index, __asset_stream_with_2, :_no_fs_, true
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

    context "create (the first unit of work)" do

      shared_subject :_custom_state_tuple do

        _custom_state_tuple_for_unit_of_work_at_index 0
      end

      it "event says it did it" do

        em = _emissions.fetch 0

        em.channel_symbol_array == %i( info expression file_write_summary created ) || fail

        _bw = em.expression_line_in_black_and_white

        _rx = /\Acreated «#{ ::Regexp.escape _this_test_file }» \([1-9]\d* lines, [1-9]\d+ bytes\)/

        _bw =~ _rx or fail
      end

      it "file content probably OK" do

        _fs = _filesystem
        io = _fs.open _this_test_file, ::File::RDONLY

        search = 'My_lib_'
        begin
          line = io.gets
          line.include? search and break
          redo
        end while above
        io.close

        line == "      ( My_lib_[ 1 + 1 ] ).should eql 3\n" || fail
      end

      def _this_test_file
        "/stub/testdir/file-21-participating-create_speg.kode"
      end
    end

    def _emissions
      _custom_state_tuple.fetch 0
    end

    def _filesystem
      _custom_state_tuple.fetch 1
    end

    def _custom_state_tuple_for_unit_of_work_at_index d

      st, el, fs = __setup

      d.times do
        st.gets
      end

      _guy = st.gets
      _hi = _guy.express_into_under :_not_used, :_expag_not_used
      _hi == :_not_used || fail

      [ el.flush_to_array, fs ]
    end

    def __setup

      fs = __build_crazy_filesystem

      _assets = fs._read_only_filesystem_._to_path_stream_

      event_log = Common_.test_support::Expect_Event::EventLog.for self

      _oes_p = event_log.handle_event_selectively

      _do_list = false

      st = _against _new_stub_index, _assets, _do_list, fs,  & _oes_p

      [ st, event_log, fs ]
    end

    def __build_crazy_filesystem

      lib = TS_::Recursion_Stubs
      _ro = lib::This_one_read_only_filesystem[]
      lib::MockFilesystem.new _ro
    end

    def __asset_stream_with_2
      _a = %w( /stub/asset/file-one /stub-asset/file/two )
      Common_::Stream.via_nonsparse_array _a
    end

    def _new_stub_index
      TS_::Recursion_Stubs::StubIndex.new
    end

    def _against cti, ppfs, do_list, fs, & any_oes_p
      _subject_mag[ cti, ppfs, do_list, fs, & any_oes_p ]
    end

    def _subject_mag
      Home_::RecursionMagnetics_::UnitOfWorkStream_via_CounterpartTestIndex_and_ProbablyParticipatingFileStream
    end
  end
end
