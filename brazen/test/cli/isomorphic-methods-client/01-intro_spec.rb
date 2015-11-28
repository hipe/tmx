require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - isomorphic methods client - 01 intro" do

    extend TS_
    use :CLI_isomorphic_methods_client

    context "a client with one action with no option parser" do

      it "make" do

        client_class_
      end

      it "build" do

        init_invocation_for_expect_stdout_stderr
      end

      it "2.3. invoke (just the arg)" do

        invoke 'yuan-jia', 'hua'
        expect :e, "«hua»"
        expect_no_more_lines
        @exitstatus.should eql :wotchaa
      end

      it "0. no args" do

        invoke
        expect :styled, :e, 'expecting <action>'
        expect :styled, :e, 'usage: zeepo <action> [..]'
        expect_generically_invited
      end

      it "1.1 strange name" do

        invoke 'bazel'
        expect_unrecognized_action :bazel
        expect :styled, :e, "known actions are ('yuan-jia')"
        expect_generically_invited
      end

      shared_subject :client_class_ do

        class TS_::CLI_IMC_01 < subject_class_

          def yuan_jia technique
            @resources.serr.puts "«#{ technique }»"
            :wotchaa
          end

          self
        end
      end
    end
  end
end
