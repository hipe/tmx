require_relative '../../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] auxiliaries - function - success" do

    TS_[ self ]
    use :my_API
    use :SES

    context "(one file one match, good function stuff)" do

      shared_subject :mutated_edit_session_ do

        _dir = the_wazizzle_worktree_
        _func_dir = common_functions_dir_

        _state = call(
          :ruby_regexp, /\bHAHA\b/,
          :path, _dir,
          :filename_pattern, '*-wazizzle.txt',
          :search,
          :replacement_expression, 'ORLY-->{{ $0.wahoo_awooga.downcase }}<--YARLY',
          :functions_directory, _func_dir,
          :replace,
        )

        _state.result.gets
      end

      shared_subject :_performance do

        mutated_edit_session_.first_match_controller.engage_replacement
      end

      it "performance succeeds" do

        expect( _performance ).to eql true
      end

      it "content looks wowzaa" do

        _performance

        want_edit_session_output_(
          "  ok oh my geez --> ORLY-->holy foxx: ahah<--YARLY <--\n" )
      end
    end
  end
end
