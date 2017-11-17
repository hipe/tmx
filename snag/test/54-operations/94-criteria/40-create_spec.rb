require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - criteria - create" do

    TS_[ self ]
    use :want_event
    use :criteria_operations

    it "action has custom syntax: can't edit and save at the same time" do

      # ((begins to) #lends-coverage to [#fi-008.4] (argument monikers))

      call_API(
        :criteria, :issues_via_criteria,
        :criteria, :hi,
        :upstream_reference, :hi,
        :save, :hi,
        :edit, :hi,
        & handle_event_selectively_ )

      want_not_OK_event :syntax,
        'can\'t simultaneously (par "save") and (par "edit")'

      want_fail
    end

    it "name must be valid" do

      call_API(
        :criteria, :issues_via_criteria,
        :criteria, %w( nodes that are tagged with #rocket ),
        :upstream_reference, :hi,
        :save, '-not-valid-',
        & handle_event_selectively_ )

      want_not_OK_event :invalid_name, "invalid name (ick_mixed \"-not-valid-\")"
      want_fail
    end

    it "yes" do

      # #lends-coverage to [#sy-008.2] (which is for us)

      fn = 'xozzo1-tmp-for-test'
      path = ::File.join criteria_directory_, fn

      require 'fileutils'

      if ::File.exist? path
        debug_IO.puts "hacking cleanup, assuming last test failed - #{ path }"
        ::FileUtils.rm path
      end

      call_API(

        :criteria, :issues_via_criteria,

        :criteria, %w( nodes that are tagged with #rocket ),

        :upstream_reference, Fixture_file_[ :hot_rocket_mani ],

        :save, fn,

        & handle_event_selectively_ )

      st = @result
      st.gets.ID.to_i.should eql 2
      st.gets.ID.to_i.should eql 4
      st.gets.ID.to_i.should eql 5
      st.gets.ID.to_i.should eql 7

      _em = want_OK_event :added_entity

      black_and_white( _em.cached_event_value ).should match(
        %r(\Aadded \"#{ fn }\" to persi) )

      ::File.read( path ).should eql "nodes that are tagged with #rocket\n"

      # cleanup ICK :

      ::FileUtils.rm path

      NIL_
    end
  end
end
