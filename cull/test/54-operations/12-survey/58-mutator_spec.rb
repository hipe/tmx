require_relative '../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] operations - survey - mutator" do

    TS_[ self ]
    use :expect_event

    it "add strange name" do

      call_API :survey, :edit,

        :add_mutator, 'zoink',
        :path, freshly_initted_path_

      expect_not_OK_event :uninitialized_constant
      expect_fail
    end

    it "add good name" do

      td = prepare_tmpdir_with_patch_ :freshly_initted

      call_API :survey, :edit,
        :add_mutator, 'remove-emp',
        :path, td.to_path

      expect_event :added_function_call

      expect_event_ :collection_resource_committed_changes

      expect_succeed

      sh = _line_shell td

      sh.advance_to_next_rx %r(\A\[report\])

      sh.next_line.should eql "function = mutator:remove-empty-actual-properties\n"

      sh.next_line.should be_nil

    end

    it "add a mutator to a temporary survey with `reduce`" do

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

      _path = dir :two_tables

      call_API( :survey,
        :reduce,
        :add_mutator, 'split-and-promote-property(misc tags, yes, ",")',
        :table_number, 1,
        :path, _path,
      )

      expect_no_events
      st = @result

      st.gets.to_even_iambic.should eql(  # empty cel is removed:
        [ :"prog lang name", "ruby" ] )

      st.gets.to_even_iambic.should eql(  # property expansion:
        [ :"prog lang name", "haskell", :functional, "yes", :difficult, "yes" ] )

      st.gets.should be_nil

    end

    it "remove a function from an existing survey (strange name)" do

      call_API :survey, :edit,
        :remove_mutator, 'nope',
        :path, dir( :one_mutator )

      expect_not_OK_event :uninitialized_constant
      expect_fail

    end

    it "remove a function (good name but not found)" do

      call_API :survey, :edit,
        :remove_mutator, "split-and-pro( sophie's chioce, true, )",
        :path, dir( :one_mutator )

      expect_not_OK_event :function_call_not_found
      expect_fail

    end

    it "remove last of three - comments and formatting preserved in the others" do

      td = prepare_tmpdir_with_patch_ :with_fuzz_biff

      call_API :survey, :edit,
        :remove_mutator, 'remove-em(x,y)',
        :path, td.to_path

      sh = _expect_remove_worked td

      sh.next_line.should be_include 'empty-act( fuz bif, true, 1.3 )'
      sh.next_line.should eql "# comment 1\n"
      sh.next_line.should be_include 'stay'
      sh.next_line.should eql "# comment 2\n"
      sh.next_line.should be_nil

    end

    it "remove first of three - also we do this hacktastic thing with comments" do

      td = prepare_tmpdir_with_patch_ :with_fuzz_biff

      call_API :survey, :edit,
        :remove_mutator, 'remove-em( fuz bif, true, 1.3 )',
        :path, td.to_path

      sh = _expect_remove_worked td

      sh.next_line.should be_include 'stay'
      sh.next_line.should be_include 'comment 2'
      sh.next_line.should be_include 'remove-empt( x, y )'
      sh.next_line.should eql "# (from removed function) comment 1\n"
      sh.next_line.should be_nil

    end

    def _expect_remove_worked td

      expect_neutral_event :removed_function_call

      expect_OK_event_ :collection_resource_committed_changes

      expect_succeed

      sh = _line_shell td
      sh.advance_to_next_rx %r(\A\[ *report *\])
      sh
    end

    def _line_shell td
      TestSupport_::Expect_line.shell content_of_the_file td
    end
  end
end
