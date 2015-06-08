require_relative 'test-support'

module Skylab::Brazen::TestSupport::CLI::Actions

  describe "[br] CLI actions status" do

    extend TS_

    with_invocation 'status'

    var = 'max num dirs'

    context "with #{ var } set to 'potato'" do

      with_max_num_dirs_ 'potato'

      it "whines about non-integer environment variable" do

        invoke 'x'

        expect :styled, /#{ env 'max-num-dirs' } must be an #{
          }integer, had #{ ick 'potato' }\z/

        expect_localized_invite_line
        expect_errored
      end
    end

    context "with #{ var } set to '-1'" do

      with_max_num_dirs_ '-1'

      it "whines about integer being too low" do

        invoke 'x'

        expect :styled, /#{ env 'max-num-dirs' } must be non-negative, #{
          }had #{ ick '-1' }/

        expect_localized_invite_line
        expect_errored
      end
    end

    context "with #{ var } set to '0'" do

      with_max_num_dirs_ '0'

      it "ok, but never does anything" do

        invoke '.'

        expect %r(\bno directories were searched\.\z)
        expect_exitstatus_for_resource_not_found
      end
    end

    context "from within an empty directory nested in another \"empty\" dir" do

      from_empty_directories_two_deep

      context "with #{ var } set to '2'" do

        with_max_num_dirs_ '2'

        it "finds nothing" do

          invoke '.'

          expect :styled,
            %r('#{ ::Regexp.escape cfg_filename }' not found in \. or 1 dir up\b)

          expect_exitstatus_for_resource_not_found
        end
      end

      context "with #{ var } set to 1" do

        with_max_num_dirs_ '1'

        it "not found, and note the language change" do
          invoke '.'
          expect_same_result
        end

        it "with no path argument, uses default of '.' (same as above)" do
          invoke
          expect_same_result
        end

        def expect_same_result
          expect :styled, %r('#{ ::Regexp.escape cfg_filename }' not found in \.)
          expect_exitstatus_for_resource_not_found
        end
      end

      context "with a path argument that does not exist" do
        it "says as much" do
          invoke 'foozie'
          expect :styled, %r(#{ par 'path' } does not exist - ./foozie\z)
          expect_action_invite_line
          expect_errored
        end
      end
    end

    # ~ ad-hoc business for this file

    def invoke * argv
      using_expect_stdout_stderr_invoke_via_argv argv
    end

    def expect_negative_exitstatus
      expect_no_more_lines
      @exitstatus.should eql Brazen_::API.exit_statii.fetch :is_negative
    end
  end
end
