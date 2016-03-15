require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types - mkdir p", wip: true do

    TS_[ self ]
    use :memoizer_methods
    use :task_types

    def subject_class_
      Task_types_[]::MkdirP
    end

    it "whines about unhandled event channels" do

      _rx = /unhandled event streams?.+all.+info/
      _cls = subject_class_

      expect_strong_failure_with_message_by_ _rx do
        _cls.new
      end
    end

    context "as empty" do

      it "whines about required arg missing if you try to run it" do

        _rx = /missing required attributes?: .*mkdir_p/

        expect_strong_failure_with_message_ _rx
      end

      def build_arguments_
        NOTHING_
      end
    end

    context "when the required parameters are present" do

      context "with regards to dry_run" do

        context "it is off (hot) by default" do

          it "like so" do

            _task = build_task_with_context_
            _task.dry_run?.should eql false
          end

          def _mkdir_p
            :hello
          end

          def context_
            EMPTY_H_
          end
        end

        context "with dry run in context" do

          it "registers that dry run is on" do

            _task = build_task_with_context_
            _task.should be_dry_run
          end

          context "when `max_depth` would be exceeded" do

            shared_state_

            it "fails (NOTE is nil)" do
              state_.result_x.should be_nil
              # fails_
            end

            it "expresses" do
              _rx = /\bmore than 1 levels deep\b/i
              error_expression_message_.should match _rx
            end

            def _max_depth
              1
            end
          end

          context "when `max_depth` is satisfied" do

            shared_state_

            it "succeeds (NOTE is n11n!)" do

              _x = state_.result_x

              ::Skylab::System::Services___::
                Filesystem::Normalizations_::
                 Existent_Directory::Mock_Dir__ == _x.class or self._WHEW
            end

            it "expresses" do
              _rx = %r(mkdir .*foo/bar)
              info_expression_message_.should match  _rx
            end

            def _max_depth
              2
            end
          end

          def context_
            { dry_run: true }
          end

          def build_arguments_
            [
              :mkdir_p, _mkdir_p,
              :max_depth, _max_depth,
            ]
          end

          def _max_depth
            0
          end

          memoize :_mkdir_p do

            _ = TestSupport_::Fixtures.dir :empty_esque_directory
            ::File.join( _, 'foo/bar' ).freeze
          end
        end
      end
    end

    def build_arguments_
      [ :mkdir_p, _mkdir_p ]
    end

    def context_
      NIL_
    end
  end
end
