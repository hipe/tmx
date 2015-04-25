require_relative '../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - message (normalization)" do

    extend TS_
    use :expect_event

    it "no false-ish'es (false)" do

      _against false
      _expect :not_a_string, "need string, had 'false'"
    end

    it "no blanks" do

      _against SPACE_
      _expect :string_has_extraordinary_features, "message was blank.: ' '"
    end

    it "no real newlines" do

      _against "x\n"

      ev = _expect :string_has_extraordinary_features,
        "message cannot contain newlines: 'x\n'"

      ev.x.should eql "x\n"
      ev.string_proc
      ev.error_category.should eql :argument_error

    end

    it "no escaped newlines" do

      _against "x\\n"

      _expect :string_has_extraordinary_features,
        "message cannot contain escaped newlines: 'x\\n'"
    end

    def _against s

      call_API :node, :create, :message, s,
        :upstream_identifier, Fixture_file_[ :rochambeaux_mani ],
        :downstream_identifier, _the_null_DS_ID

    end

    def _expect sym, s
      ev = expect_not_OK_event sym
      black_and_white( ev ).should eql s
      expect_failed
      ev.to_event
    end

    memoize_ :_the_null_DS_ID do
      :HI
    end
  end
end