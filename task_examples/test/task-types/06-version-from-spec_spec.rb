require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types version from spec", wip: true do

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

          _expect_only_string 'version 1.2.34 is the version'
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
            __expect_only_version '1.3.78'
          end

          def _version_from
            'echo "ver 1.3.78 is it"'
          end
        end

        context 'against a non-matching output' do

          shared_state_

          it "succeeds" do
            succeeds_
          end

          it "shows all of the output" do
            _expect_only_string 'ver A.B.foo'
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

        it "fails with message (LOOK)" do

          _rx = %r(\A Bad range assertion)
          expect_strong_failure_with_message_ _rx
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

          _rx = %r(\ADo not use "[^"]+" as a target #{
            }without a "must be in range" assertion\b)

          expect_strong_failure_with_message_ _rx
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

            _expect_version_mismatch_against '0.0.1'
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

        it "reports a failure (SMALL ISSUE HERE)" do

          _expect_version_mismatch_against "version A.B.C"
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

      def _expect_version_mismatch_against s

        _s_ = "version mismatch: needed 1.2+ had #{ s }"

        expect_only_ :styled, :info, _s_
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

    def __expect_only_version s

      _rx = /\Aversion: #{ ::Regexp.escape s }\z/

      payload_expression_message_.should match _rx
    end

    def _expect_only_string s

      payload_expression_message_.should eql "version: #{ s }"
    end

    def __expect_OK s

      info_expression_message_.should eql "version ok: #{ s }"
    end
  end
end
