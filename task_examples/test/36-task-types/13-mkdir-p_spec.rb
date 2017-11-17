require_relative '../test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] task-types - mkdir p" do

    # #signficance: tasks no longer result in data payloads..

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :task_types

    def subject_class_
      Task_types_[]::MkdirP
    end

    def build_arguments_
      [
        :dry_run, _dry_run,
        :max_depth, _max_depth,
        :mkdir_p, _mkdir_p,
      ]
    end

    context "essential" do

      shared_state_

      it "loads" do
        subject_class_
      end

      it "whines about required arg missing if you try to run it" do

        want_missing_required_attributes_are_ :mkdir_p
      end

      def build_arguments_
        EMPTY_A_
      end
    end

    context "dry run, max depth is exceeded" do

      shared_state_

      def _max_depth
        1
      end

      def _mkdir_p
        _mkdir_p_where_two_directories_would_have_to_be_created
      end

      it "fails" do
        fails_
      end

      it "expresses" do

        _be_msg = be_include "would have to create at least 2 directories, #{
          }only allowed to make 1"

        _be = be_emission :error, :path_too_deep do |ev|
          _ = black_and_white ev
          _.should _be_msg
        end

        only_emission.should _be
      end
    end

    context "dry run when `max_depth` is satisfied" do

      shared_state_

      def _max_depth
        2
      end

      def _mkdir_p
        _mkdir_p_where_two_directories_would_have_to_be_created
      end

      it "succeeds" do
        succeeds_
      end

      it "emits" do

        _be_msg = match %r(\Acreating directory - «.+/foo/bar»\z)

        _be_this = be_emission :info, :creating_directory do |ev|
          _ = black_and_white ev
          _.should _be_msg
        end

        only_emission.should _be_this
      end

      it "side-effects are written to the task itself" do

        _task = state_.task

        _x = _task.created_directory

        _x.is_mock_directory or fail
      end
    end

    def _dry_run
      true
    end

    def _mkdir_p_where_two_directories_would_have_to_be_created

      _ = the_empty_directory_
      ::File.join _, 'foo/bar'
    end
  end
end
# #tombstone: unhandled event streams
