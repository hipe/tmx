require_relative '../../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] models - survey mutators" do

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

    it "try it on a temporary survey" do

      call_API :survey,

        :reduce,

        :upstream, file( :mutators_01_simple_md ),

        :add_mutator, 'remove-empty'

      expect_no_events

      st = @result
      ent = st.gets
      ent_ = st.gets
      st.gets.should be_nil

      ent.to_even_iambic.should eql [ :"prog lang name", "ruby" ]
      ent_.to_even_iambic.should eql [ :"prog lang name", "haskell", :monads, "yes" ]
    end

    it "take an existing survey, add a function, run it (does not persist)" do

      call_API :survey,

        :reduce,

        :add_mutator, 'split-and-promote-property(misc tags, yes, ",")',

        :table_number, 1,

        :path, TS_::Fixtures::Directories[ :two_tables ]

      expect_no_events
      st = @result

      st.gets.to_even_iambic.should eql(  # empty cel is removed:
        [ :"prog lang name", "ruby" ] )

      st.gets.to_even_iambic.should eql(  # property expansion:
        [ :"prog lang name", "haskell", :functional, "yes", :difficult, "yes" ] )

      st.gets.should be_nil

    end
  end
end
