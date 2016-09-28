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

        _st = against_ the_stub_index_, __the_asset_stream, :_no_VCS_, :_no_fs_, true
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
          _unit.asset_path == "/stub/asset/file-one.zink" || fail
        end

        it "knows test path" do
          _unit.test_path == "/stub/testz/file-one_speg.zink" || fail
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
        _a = %w( /stub/asset/file-one.zink /stub-asset/file/two.zonk )
        Stream_[ _a ]
      end

      shared_subject :the_stub_index_ do

        si = TS_::Recursion_Stubs::StubIndex.new
        si.have_no_test_file_for 'file-one'
        si.have_test_file_for 'two'
        si
      end
    end

    _test_file_21 = '/stub/testz/file-21-participating-create_speg.kerd'
    _test_file_22 = '/stub/testz/file-22-participating-but-changes_speg.kerd'
    _test_file_23 = '/stub/testz/file-23-participating-clobberin-time_speg.kerd'

    esc = ::Regexp.method :escape

    context "a minimal normative recursive 'synchronize' operation (mocked)" do

      given_these_system_resources do

        lib = TS_::Recursion_Stubs

        filesystem_by do
          _ro = lib::This_one_read_only_filesystem[]
          lib::MockFilesystem.new _ro
        end

        _VCS_reader_by do
          o = lib::VCS_Reader.new
          o.this_is_a_file_that_is_versioned_but_has_changes _test_file_22
          o.this_is_a_file_that_is_versioned_and_has_no_changes _test_file_23
          o
        end
      end

      shared_subject :the_stub_index_ do
        si = TS_::Recursion_Stubs::StubIndex.new
        si.have_no_test_file_for 'file-21-participating-create'
        si.have_test_file_for 'file-22-participating-but-changes'
        si.have_test_file_for 'file-23-participating-clobberin-time'
        si
      end

      context "for an asset file whose test file is not yet written" do

        def the_unit_of_work_index_
          0
        end

        it "the emission channel has 'created' in it" do
          the_emission_.channel_symbol_array == _channel_for( :created ) || fail
        end

        it "the emission content makes sense" do
          _act = the_emission_.expression_line_in_black_and_white
          _exp = /\Acreated «#{ esc[ _test_file_21 ] }» \([1-9]\d* lines, [1-9]\d+ bytes\)/
          _act =~ _exp || fail
        end

        it "the content of the created file looks right" do
          _line = find_line_with_ 'My_lib_', _test_file_21
          _line == "      ( My_lib_[ 1 + 1 ] ).should eql 3\n" || fail
        end
      end

      context "for an asset file whose test file has unversioned changes" do

        def the_unit_of_work_index_
          1
        end

        it "the emission channel has 'skipped' in it" do
          the_emission_.channel_symbol_array == _channel_for( :skipped ) || fail
        end

        it "the emission content takin bout unversioned changes" do
          _act = the_emission_.expression_line_in_black_and_white
          _exp = /\Askipping because has changes: «#{ esc[ _test_file_22 ] }»/
          _act =~ _exp || fail
        end
      end

      context "for an asset file whose test file exists but is versioned CLOBBER!" do

        def the_unit_of_work_index_
          2
        end

        it "the emission channel has 'updated' in it" do
          the_emission_.channel_symbol_array == _channel_for( :updated ) || fail
        end

        it "the emission talkin bout updated" do
          _act = the_emission_.expression_line_in_black_and_white
          _exp = /\Aupdated «#{ esc[ _test_file_23 ] }» \([1-9]\d* lines, [1-9]\d+ bytes\)/
          _act =~ _exp or fail
        end

        it "the content of the created file looks right" do

          _act_st = open_possibly_mocked_file_readonly_ _test_file_23

          _exp_s = <<-HERE.unindent
            this old test content *is* versioned

              it "xx" do
                3.should eql 4
              end
          HERE

          _exp_st = Line_stream_via_string_[ _exp_s ]

          TestSupport_::Expect_Line::Streams_have_same_content[ _act_st, _exp_st, self ]
        end
      end
    end

    # -- support for the mutating operation

    def _channel_for sym
      [ :info, :expression, :file_write_summary, sym ]
    end

    # -- support for all sub-operations



    def against_ cti, ppfs, do_list, vcs_rdr, fs, & any_oes_p
      _subject_mag[ cti, ppfs, do_list, vcs_rdr, fs, & any_oes_p ]
    end

    def _subject_mag
      Home_::RecursionMagnetics_::UnitOfWorkStream_via_CounterpartTestIndex_and_ProbablyParticipatingFileStream
    end
  end
end
