require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - node - actions - close" do

    extend TS_
    use :expect_event
    use :downstream_redirect_to_string

    it "closing one with a funny looking name - whines gracefully" do

      _against 'abc'
      expect_failed_by :uninterpretable_under_number_set
    end

    it "closing one that doesn't exist - whines gracefully" do

      _against '867'
      expect_failed_by :entity_not_found
    end

    it "closing one that is already closed - whines gracefully" do

      _against '002'
      _expect :entity_not_found, "[#2] does not have #open"
      _expect :entity_already_added, "[#2] already has #done"
      expect_failed
    end

    it "closing one that has no taggings at all - works, reindents" do

      _DS_ID downstream_ID_around_input_string_

      _against '001'

      _ev = expect_neutral_event :entity_not_found
      black_and_white( _ev ).should eql "[#1] does not have #open"
      expect_succeeded

      # (to do the above we do the crazy error caching / mutating experiment)

      scn = scanner_via_output_string_

      s = scn.advance_N_lines 4

      s.should eql(
        "[#001]       #done this one has no markings and 6 spaces of ws\n" )
      # the above now has 7 spaces in the submargin where before it had 6

      scn.next_line.should be_nil
    end

    it "closing one that is open and has multiline - works, munges lines" do

      _DS_ID downstream_ID_around_input_string_
      _against '0003'

      expect_OK_event :entity_removed, "removed #open from [#3]"

      scn = scanner_via_output_string_

      scn.next_line.should eql "[#003]       #done biff bazz\n"

      scn.next_line.should eql(
        "             this 2nd line indents#{
          } but does not concat onto the first\n" )

      scn.next_line[ 0, 6 ].should eql '[#002]'
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
