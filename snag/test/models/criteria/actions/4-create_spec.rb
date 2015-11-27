require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - criteria - create" do

    extend TS_
    use :expect_event
    use :models_criteria_actions

    it "action has custom syntax: can't edit and save at the same time" do

      call_API(
        :criteria, :criteria_to_stream,
        :criteria, :hi,
        :upstream_identifier, :hi,
        :save, :hi,
        :edit, :hi,
        & handle_event_selectively )

      expect_not_OK_event :syntax,
        'can\'t simultaneously (par "save") and (par "edit")'

      expect_failed
    end

    it "name must be valid" do

      call_API(
        :criteria, :criteria_to_stream,
        :criteria, %w( nodes that are tagged with #rocket ),
        :upstream_identifier, :hi,
        :save, '-not-valid-',
        & handle_event_selectively )

      expect_not_OK_event :invalid_name, "invalid name (ick \"-not-valid-\")"
      expect_failed
    end

    it "yes" do

      fn = 'xyzzy1-tmp-for-test'
      path = ::File.join criteria_directory_, fn

      require 'fileutils'

      if ::File.exist? path
        debug_IO.puts "hacking cleanup, assuming last test failed - #{ path }"
        ::FileUtils.rm path
      end

      call_API(

        :criteria, :criteria_to_stream,

        :criteria, %w( nodes that are tagged with #rocket ),

        :upstream_identifier, Fixture_file_[ :hot_rocket_mani ],

        :save, fn,

        & handle_event_selectively )

      st = @result
      st.gets.ID.to_i.should eql 2
      st.gets.ID.to_i.should eql 4
      st.gets.ID.to_i.should eql 5
      st.gets.ID.to_i.should eql 7

      _ev = expect_OK_event :component_added
      black_and_white( _ev ).should match %r(\Aadded \"#{ fn }\" to persi)

      ::File.read( path ).should eql "nodes that are tagged with #rocket\n"

      # cleanup ICK :

      ::FileUtils.rm path

      NIL_
    end
  end
end
