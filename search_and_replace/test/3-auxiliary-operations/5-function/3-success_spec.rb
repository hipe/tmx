require_relative '../../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] auxiliaries - function - (3) success" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :operations
    use :magnetics_mutable_file_session

    context "(one file one match, good function stuff)" do

      shared_subject :edit_session_ do

        _dir = the_wazizzle_worktree_
        _func_dir = common_functions_dir_

        call_(
          :ruby_regexp, /\bHAHA\b/,
          :path, _dir,
          :filename_pattern, '*-wazizzle.txt',
          :search,
          :replacement_expression, 'ORLY-->{{ $0.wahoo_awooga.downcase }}<--YARLY',
          :functions_directory, _func_dir,
          :replace,
        )

        @result.gets
      end

      shared_subject :_performance do

        edit_session_.first_match_controller.engage_replacement
      end

      it "performance succeeds" do

        _performance.should eql true
      end

      it "content looks wowzaa" do

        _performance

        expect_edit_session_output_(
          "  ok oh my geez --> ORLY-->holy foxx: ahah<--YARLY <--\n" )
      end
    end
  end
end
