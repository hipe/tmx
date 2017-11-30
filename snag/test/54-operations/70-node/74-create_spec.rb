require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - node - create" do

    TS_[ self ]
    use :want_event
    use :byte_up_and_downstreams
    use :nodes

    it "uses first available ID, placed in correct spot (integration)" do

      call_API :node, :create, :message, 'ziff dizzle',
        :upstream_reference, Fixture_file_[ :rochambeaux_mani ],
        :downstream_reference, downstream_ID_for_output_string_ivar_

      # (was [#033] flickering test per setup tmpdir)

      scn = scanner_via_output_string_
      expect( scn.next_line ).to eql "[#04] #open feep my deep\n"
      expect( scn.next_line ).to eql "not business\n"
      expect( scn.next_line ).to eql "[#003]       ziff dizzle\n"
      expect( scn.next_line ).to eql "[#02]       #done wizzle bizzle 2013-11-11\n"
      expect( scn.next_line ).to eql "               one more line\n"
      expect( scn.next_line ).to eql NEWLINE_
      expect( scn.next_line ).to eql "[#01]       #hi\n"
      expect( scn.next_line ).to be_nil

      want_noded_ 3
    end
  end
end
