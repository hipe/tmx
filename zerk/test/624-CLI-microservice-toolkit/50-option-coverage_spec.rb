require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI microservice toolkit - o.p coverage" do

    # (this is now somewhat of a stub)

    TS_[ self ]
    use :CLI_microservice_toolkit

    context "no o.p" do

      it "when no o.p, **option-looking args are still parsed as opts**" do

        invoke '-x'
        want :e, "invalid option: -x"
        want_result_for_failure
      end

      shared_subject :client_class_ do

        class CLI_IMC_05_nop < subject_class_

          def foo x
            "ok:(#{ x })"
          end

          self
        end
      end
    end
  end
end

# :+#tombstone: tests for custom o.p class
