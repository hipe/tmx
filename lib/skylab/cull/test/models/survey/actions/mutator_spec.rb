require_relative '../../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] models - survey mutator add" do

    Expect_event_[ self ]

    extend TS_

    it "add strange name" do

      call_API :survey, :edit,

        :add_mutator, 'zoink',
        :path, freshly_initted_path

      expect_not_OK_event :uninitialized_constant
      expect_failed
    end

    it "add good name" do

      td = prepare_tmpdir_with_patch :freshly_initted

      call_API :survey, :edit,
        :add_mutator, 'remove-emp',
        :path, td.to_path

      expect_event :added_function_call

      expect_event :datastore_resource_committed_changes

      expect_succeeded

      sh = TestSupport_::Expect_line.shell content_of_the_file td

      sh.advance_to_next_rx %r(\A\[report\])

      sh.next_line.should eql "function = mutator:remove-empty-actual-properties\n"

      sh.next_line.should be_nil

    end
  end
end
