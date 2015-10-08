require_relative '../../../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] S & R - features - functions" do

    extend TS_
    use :models_search_and_replace

    it "when you use a strange function name (but have a function folder)" do

      _cd _first_workspace

      call_API :search, /wazoo/i,
        :replace, '{{ $0.downcase.well_well_well.nope }}',
        :dirs, TS_._COMMON_DIR,
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

    it "**non-interactive** search and replace thru API call" do

      start_tmpdir_
      to_tmpdir_add_wazoozle_file_

      _cd _first_workspace

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

    def _cd path
      Home_.lib_.file_utils.cd path
    end

    def _first_workspace
      my_fixture_files_.STFU_OMG_WORKSPACE_PATH
    end
  end
end
