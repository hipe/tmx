require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - node - actions - close" do

    extend TS_
    use :expect_event
    use :byte_up_and_downstreams
    use :node_support

    it "closing one with a funny looking name - whines gracefully" do

      _against 'abc'
      expect_failed_by :uninterpretable_under_number_set
    end

    it "closing one that doesn't exist - whines gracefully" do

      _against '867'
      expect_failed_by :component_not_found
    end

    it "closing one that is already closed - whines gracefully" do

      _against '002'
      _expect :component_not_found, "node [#2] does not have tag '#open'"
      _expect :entity_already_added, "[#2] already has #done"
      expect_neutralled
    end

    it "closing one that has no taggings at all - works, reindents" do

      _DS_ID downstream_ID_for_output_string_ivar_

      _against '001'

      _ev = expect_not_OK_event :component_not_found
      black_and_white( _ev ).should eql "node [#1] does not have tag '#open'"

      expect_noded_ 1

      scn = scanner_via_output_string_

      s = scn.advance_N_lines 5

      s.should eql(
        "[#001]       #done this one has no markings and 6 spaces of ws\n" )
      # the above now has 7 spaces in the submargin where before it had 6

      scn.next_line.should be_nil
    end

    it "closing one that is open and has multiline - works, munges lines" do

      _DS_ID downstream_ID_for_output_string_ivar_
      _against '0003'

      expect_OK_event :entity_removed, "removed tag #open from node [#3]"

      @output_s.should eql <<-O
[#003]       #done biff bazz this 2nd will get flowed into the previous one
             because it was edited (this line too).
[#002]       #done this one is finished
[#001]      this one has no markings and 6 spaces of ws
      O
    end

    def __DS_ID

      # we have this always be something to prevent ourselves from
      # accidentally modifying the fixture files during development

      _DS_ID_x || :_fake_DS_ID_never_used_

    end

    attr_reader :_DS_ID_x

    def _DS_ID x
      @_DS_ID_x = x
    end

    def _against s

      call_API :node, :close,

        :upstream_identifier, Fixture_file_[ :for_close_mani ],
        :downstream_identifier, __DS_ID,
        :node_identifier, s

    end

    def _expect sym, s

      ev = expect_not_OK_event sym
      black_and_white( ev ).should eql s
      NIL_
    end
  end
end
