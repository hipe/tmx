require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types version from spec" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :task_types

    def subject_class_
      Task_types_[]::VersionFrom
    end

    context "essential" do

      it "loads" do
        subject_class_
      end
    end

    context "when reporting a version" do

      def _do_show_version
        true
      end

      context 'without using a regex' do

        shared_state_

        it "succeeds" do
          succeeds_
        end

        it "just reports the output" do
          _expect_labelled_as_version 'version 1.2.34 is the version'
        end

        def _parse_with
          NIL_
        end
      end

      context 'with a regex' do

        context('against a matching output') do

          shared_state_

          it "succeeds" do
            succeeds_
          end

          it "shows the matched portion of the output" do
            _expect_labelled_as_version '1.3.78'
          end

          def _version_from
            'echo "ver 1.3.78 is it"'
          end
        end

        context 'against a non-matching output' do

          shared_state_

          it "fails" do
            fails_
          end

          it "explains that it can't parse" do
            _be_this = _be_couldnt_parse "ver A.B.foo\n"
            error_expression_message_.should _be_this
          end

          def _version_from
            'echo "ver A.B.foo"'
          end
        end
      end
    end

    context "when checking a version" do

      context "with a bad 'must_be_in_range' assertion" do

        shared_state_

        it "fails with message" do

          _ = error_expression_message_

          _rx = %r(\ABad range assertion)

          _.should match _rx
        end

        def _version_from
          '1.2+'
        end

        def _must_be_in_range
          '~> 1.2'
        end
      end

      context "without a 'must_be_in_range' assertion" do

        shared_state_

        it "fails" do
          fails_
        end

        it "emits" do

          _rx = %r(\ADo not use "[^"]+" as a target #{
            }without a "must be in range" assertion\b)

          error_expression_message_.should match _rx
        end

        def _must_be_in_range
          NIL_
        end
      end

      context "when the regex matches" do

        context "and the version matches" do

          shared_state_

          it "succeeds" do
            succeeds_
          end

          it "says that it matches" do

            __expect_OK 'version 1.2.1 is in range 1.2+'
          end

          def _version_from
            'echo "ver 1.2.1"'
          end
        end

        context "and the version does not match" do

          shared_state_

          it "fails" do
            fails_
          end

          it "says that is doesn't match" do

            _be_this = _be_version_mismatch_against '0.0.1'
            error_expression_message_.should _be_this
          end

          def _version_from
            'echo "version 0.0.1"'
          end
        end

        def context_
          NIL_
        end
      end

      context "when the regex does not match" do

        shared_state_

        it "fails" do
          fails_
        end

        it "reports a failure" do

          _be_this_message = _be_couldnt_parse "version A.B.C\n"

          error_expression_message_.should _be_this_message
        end

        def _version_from
          'echo "version A.B.C"'
        end
      end

      def context_
        EMPTY_H_
      end

      def _must_be_in_range
        '1.2+'
      end

      def _be_version_mismatch_against s

        eql "version mismatch: needed 1.2+ had #{ s.inspect }"
      end
    end

    def build_arguments_
      [
        :must_be_in_range, _must_be_in_range,
        :parse_with, _parse_with,
        :show_version, _do_show_version,
        :version_from, _version_from,
      ]
    end

    def _do_show_version
      false
    end

    def _must_be_in_range
      NIL_
    end

    def _parse_with
      '/(\d+\.\d+\.\d+)/'
    end

    def _version_from
      'echo "version 1.2.34 is the version"'
    end

    def _be_couldnt_parse s
      _ = s.inspect
      eql "using provided regex, couldn't parse version from #{ _ }"
    end

    def _expect_labelled_as_version s

      payload_expression_message_.should eql "version: #{ s }"
    end

    def __expect_OK s

      info_expression_message_.should eql "version ok: #{ s }"
    end

    def expression_agent_for_expect_emission
      common_expression_agent_for_expect_emission_
    end
  end
end
