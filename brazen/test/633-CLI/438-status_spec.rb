require_relative '../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI (actions) status" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_actions

    with_invocation 'status'

    var = 'max num dirs'

    context "with #{ var } set to 'potato'" do

      with_max_num_dirs_ 'potato'

      it "whines about non-integer environment variable" do

        invoke 'x'

        want :styled, /#{ env 'max-num-dirs' } must be an #{
          }integer, had #{ ick 'potato' }\z/

        want_localized_invite_line
        want_errored
      end
    end

    context "with #{ var } set to '-1'" do

      with_max_num_dirs_ '-1'

      it "whines about integer being too low" do

        invoke 'x'

        want :styled, /#{ env 'max-num-dirs' } must be non-negative, #{
          }had #{ ick( -1 ) }/

        want_localized_invite_line
        want_errored
      end
    end

    context "with #{ var } set to '0'" do

      with_max_num_dirs_ '0'

      it "ok, but never does anything" do

        invoke '.'

        want %r(\bno directories were searched\.\z)
        want_exitstatus_for_resource_not_found
      end
    end

    context "from within an empty directory nested in another \"empty\" dir" do

      from_empty_directories_two_deep

      context "with #{ var } set to '2'" do

        with_max_num_dirs_ '2'

        it "finds nothing" do

          invoke '.'

          want "#{ _head } not found in . or 1 dir up"

          want_exitstatus_for_resource_not_found
        end
      end

      context "with #{ var } set to 1" do

        with_max_num_dirs_ '1'

        it "not found, and note the language change" do
          invoke '.'
          want_same_result
        end

        it "with no path argument, uses default of '.' (same as above)" do
          invoke
          want_same_result
        end

        def want_same_result
          want "#{ _head } not found in ."
          want_exitstatus_for_resource_not_found
        end
      end

      context "with a path argument that does not exist" do

        it "says as much" do  # #lends-coverage to #[#fi-008.6]
          invoke 'foozie'
          want :styled, %r(#{ par 'path' } does not exist - \./foozie\z)
          want_action_invite_line_
          want_errored
        end
      end
    end

    # ~ ad-hoc business for this file

    def invoke * argv
      using_want_stdout_stderr_invoke_via_argv argv
    end

    dangerous_memoize :_head do
      'while determining a workspace, "brazen.conf"'
    end

    def want_negative_exitstatus
      want_no_more_lines
      @exitstatus.should eql Home_::API.exit_statii.fetch :is_negative
    end
  end
end
