require_relative '../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] operations - survey - mutator", wip: true do

    TS_[ self ]
    use :want_event

# (1/N)
    it "add strange name" do

      call_API :survey, :edit,

        :add_mutator, 'zoink',
        :path, freshly_initted_path_

      want_not_OK_event :uninitialized_constant
      want_fail
    end

# (2/N)
    it "add good name" do

      td = prepare_tmpdir_with_patch_ :freshly_initted

      call_API :survey, :edit,
        :add_mutator, 'remove-emp',
        :path, td.to_path

      want_event :added_function_call

      want_event_ :collection_resource_committed_changes

      want_succeed

      sh = _line_shell td

      sh.advance_to_next_rx %r(\A\[report\])

      expect( sh.next_line ).to eql "function = mutator:remove-empty-actual-properties\n"

      expect( sh.next_line ).to be_nil

    end

# (3/N)
    it "add a mutator to a temporary survey with `reduce`" do

      call_API :survey,

        :reduce,

        :upstream, file( :mutators_01_simple_md ),

        :add_mutator, 'remove-empty'

      want_no_events

      st = @result
      ent = st.gets
      ent_ = st.gets
      expect( st.gets ).to be_nil

      expect( ent.to_even_iambic ).to eql [ :"prog lang name", "ruby" ]
      expect( ent_.to_even_iambic ).to eql [ :"prog lang name", "haskell", :monads, "yes" ]
    end

# (4/N)
    it "take an existing survey, add a function, run it (does not persist)" do

      _path = dir :two_tables

      call_API( :survey,
        :reduce,
        :add_mutator, 'split-and-promote-property(misc tags, yes, ",")',
        :table_number, 1,
        :path, _path,
      )

      want_no_events
      st = @result

      expect( st.gets.to_even_iambic ).to eql(  # empty cel is removed:
        [ :"prog lang name", "ruby" ] )

      expect( st.gets.to_even_iambic ).to eql(  # property expansion:
        [ :"prog lang name", "haskell", :functional, "yes", :difficult, "yes" ] )

      expect( st.gets ).to be_nil

    end

# (5/N)
    it "remove a function from an existing survey (strange name)" do

      call_API :survey, :edit,
        :remove_mutator, 'nope',
        :path, dir( :one_mutator )

      want_not_OK_event :uninitialized_constant
      want_fail

    end

# (6/N)
    it "remove a function (good name but not found)" do

      call_API :survey, :edit,
        :remove_mutator, "split-and-pro( sophie's chioce, true, )",
        :path, dir( :one_mutator )

      want_not_OK_event :function_call_not_found
      want_fail

    end

# (7/N)
    it "remove last of three - comments and formatting preserved in the others" do

      td = prepare_tmpdir_with_patch_ :with_fuzz_biff

      call_API :survey, :edit,
        :remove_mutator, 'remove-em(x,y)',
        :path, td.to_path

      sh = _want_remove_worked td

      expect( sh.next_line ).to be_include 'empty-act( fuz bif, true, 1.3 )'
      expect( sh.next_line ).to eql "# comment 1\n"
      expect( sh.next_line ).to be_include 'stay'
      expect( sh.next_line ).to eql "# comment 2\n"
      expect( sh.next_line ).to be_nil

    end

# (8/N)
    it "remove first of three - also we do this hacktastic thing with comments" do

      td = prepare_tmpdir_with_patch_ :with_fuzz_biff

      call_API :survey, :edit,
        :remove_mutator, 'remove-em( fuz bif, true, 1.3 )',
        :path, td.to_path

      sh = _want_remove_worked td

      expect( sh.next_line ).to be_include 'stay'
      expect( sh.next_line ).to be_include 'comment 2'
      expect( sh.next_line ).to be_include 'remove-empt( x, y )'
      expect( sh.next_line ).to eql "# (from removed function) comment 1\n"
      expect( sh.next_line ).to be_nil

    end

    def _want_remove_worked td

      want_neutral_event :removed_function_call

      want_OK_event_ :collection_resource_committed_changes

      want_succeed

      sh = _line_shell td
      sh.advance_to_next_rx %r(\A\[ *report *\])
      sh
    end

    def _line_shell td
      TestSupport_::Want_line.shell content_of_the_file td
    end
  end
end
