require_relative '../test-support'

module Skylab::SubTree::TestSupport

  describe "[st] CLI - files - cannon" do

    TS_[ self ]
    use :CLI_for_files

    it "1.2 : one unrec opt : msg / usage / invite" do

      local_invoke '-x'

      want 'invalid option: -x'
      want "use 'stflz files -h' for help"
      want_errored_generically
    end

    it "1.4 one rec opt : -h (as prefix) - beautiful help screen" do

      invoke '-h', 'files'

      _want_beautiful_help
    end

    it "1.4 one rec opt : -h (as postfix) - beautiful help screen" do

      invoke 'files', '-h'

      _want_beautiful_help
    end

    it "expag says 'both'" do

      # for earlier detection of errors we usually place lower-level, "unit"-
      # like tests either eariler in the file or at a file of shallower depth.
      # but in this case we place this test later so that we cover that the
      # expag is autoloaded by the app and not by us. :(

      _expag = produce_action_specific_expag_safely_

      _s = _expag.calculate do

        a = [ par_via_sym( :foo_bar ), par_via_sym( :baz ) ]

        "#{ both( a ) }#{ and_ a } are ok."
      end

      _s.should eql 'both «foo-bar» and «baz» are ok.'
    end

    def _want_beautiful_help

      ( 18 .. 20 ).should be_include(

        @IO_spy_group_for_want_stdout_stderr.lines.length )
    end
  end
end
# :+#tombstone: tons of byzantine regex assertions
