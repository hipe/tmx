require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - node - create errors" do

    # (this was originally positioned as the model test for Message but
    # because of the manner in which is it tested it must be here instead.)

    TS_[ self ]
    use :want_event

    it "no false-ish'es (false)" do  # #lends-coverage to [#pl-008.2]

      _against false
      _expect :not_a_string, "need string, had false"
    end

    it "no blanks" do

      _against SPACE_
      _expect :string_has_extraordinary_features, 'message was blank.: " "'
    end

    it "no real newlines" do

      _against "x\n"

      ev = _expect :string_has_extraordinary_features,
        'message cannot contain newlines: "x\n"'

      expect( ev.x ).to eql "x\n"
      ev.string_proc
      expect( ev.error_category ).to eql :argument_error
    end

    it "no escaped newlines" do

      _against "x\\n"

      _expect :string_has_extraordinary_features,
        'message cannot contain escaped newlines: "x\\\\n"'
        # (that's two real bytes to express two real backslashes)
    end

    def _against s

      call_API :node, :create, :message, s,
        :upstream_reference, Fixture_file_[ :rochambeaux_mani ],
        :downstream_reference, _the_null_DS_ID
    end

    def _expect sym, s

      ev = want_not_OK_event( sym ).cached_event_value

      expect( black_and_white ev ).to eql s

      want_fail

      ev.to_event
    end

    memoize :_the_null_DS_ID do
      :HI
    end
  end
end
