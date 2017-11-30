require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI microservice toolkit - 01 intro" do

    TS_[ self ]
    use :CLI_microservice_toolkit

    it "loads" do
      subject_class_ || fail
    end

    context "a client with one action with no option parser" do

      it "make" do
        client_class_
      end

      it "2.3. invoke (just the arg)" do

        invoke 'yuan-jia', 'hua'
        want :e, "«hua»"
        want_no_more_lines
        expect( @exitstatus ).to eql :wotchaa
      end

      it "0. no args" do

        invoke
        want :styled, :e, 'expecting <action>'
        want :styled, :e, 'usage: zeepo <action> [..]'
        want_generically_invited
      end

      it "1.1 strange name" do

        invoke 'bazel'
        want_unrecognized_action :bazel
        want :styled, :e, "known actions are ('yuan-jia')"
        want_generically_invited
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
