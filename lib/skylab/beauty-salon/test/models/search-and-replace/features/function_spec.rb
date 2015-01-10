require_relative '../test-support'

module Skylab::BeautySalon::TestSupport::Models::Search_and_Replace

  describe "[bs] S & R - features - functions" do

    TestLib_::Expect_event[ self ]

    extend TS_

    it "when you use a strange function name (but have a function folder)" do

      cd first_workspace

      call_API :search, /wazoo/i,
        :replace, '{{ $0.downcase.well_well_well.nope }}',
        :dirs, TestSupport_::Data.dir_pathname.join( 'universal-fixtures' ).to_path,
        :files, '*-line*.txt',
        :preview,
        :matches,
        :grep,
        :replace

      ev = expect_not_OK_event :missing_function_definitions

      black_and_white( ev ).should eql(
        "replace error: 'well_well_well' and 'nope' are missing #{
         }the expected files #{
          }«.search-and-replace/functions/{well-well-well.rb, nope.rb}»" )

      expect_failed
    end

    it "OMG HOLY RIDICULOUS S & R API WITH FUNCTION" do

      start_tmpdir
      to_tmpdir_add_wazoozle_file

      cd first_workspace

      call_API :search, /\bHAHA\b/,
        :replace, 'ORLY-->{{ $0.stfu_omg.downcase }}<--YARLY',
        :dirs, @tmpdir.to_path,
        :files, '*-wazoozle.txt',
        :preview,
        :matches,
        :grep,
        :replace

      _match = @result.gets
      @result.gets.should be_nil

      expect_neutral_event :grep_command_head
      expect_OK_event :changed_file

      _s = ::File.read @tmpdir.join( 'ok-whatever-wazoozle.txt' ).to_path
      _s.should eql "ok oh my geez --> ORLY-->holy foxx: ahah<--YARLY <--\n"

    end

    def cd path
      BS_.lib_.file_utils.cd path
    end

    def first_workspace
      TS_::Fixtures.stfu_omg_workspace_path
    end
  end
end
