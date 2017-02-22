require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - node - create" do

    TS_[ self ]
    use :expect_event
    use :byte_up_and_downstreams
    use :nodes

    it "uses first available ID, placed in correct spot (integration)" do

      call_API :node, :create, :message, 'ziff dizzle',
        :upstream_identifier, Fixture_file_[ :rochambeaux_mani ],
        :downstream_identifier, downstream_ID_for_output_string_ivar_

      # (was [#033] flickering test per setup tmpdir)

      scn = scanner_via_output_string_
      scn.next_line.should eql "[#04] #open feep my deep\n"
      scn.next_line.should eql "not business\n"
      scn.next_line.should eql "[#003]       ziff dizzle\n"
      scn.next_line.should eql "[#02]       #done wizzle bizzle 2013-11-11\n"
      scn.next_line.should eql "               one more line\n"
      scn.next_line.should eql NEWLINE_
      scn.next_line.should eql "[#01]       #hi\n"
      scn.next_line.should be_nil

      expect_noded_ 3
    end
  end
end
