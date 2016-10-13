require_relative 'test-support'

module Skylab::CSS_Convert::TestSupport

  describe "[cssc] CLI integration" do

    TS_[ self ]
    use :my_CLI_expectations

    it "with no args, gives warm, inviting message" do

      invoke
      expect :styled, :e, 'expecting <action>'
      expect_usaged_and_invited
    end

    it "with no args to action, gives helpful message" do

      invoke 'convert'
      expect :styled, :e, "expecting: <directives-file>"
      _expect_specific_usaged_and_invited
    end

    it "with too many args, should give friendly, " <<
      "not overbearing emotional support" do

      invoke 'convert', 'alpha', 'beta'
      expect :e, "unexpected argument \"beta\""
      _expect_specific_usaged_and_invited
    end

    it "should whine about file not found" do

      _path = fixture_path_ 'not-there.txt'
      invoke 'convert', _path
      expect :e, /\Afailed because no such file or directory - .+\/fixture-files\/not-there\.txt\z/i

      expect_specific_invite_line_to :convert
      expect_no_more_lines
      @exitstatus.should eql Home_::Brazen_::API.exit_statii.fetch :resource_not_found
    end

    def _expect_specific_usaged_and_invited

      expect :styled, :e, /\Ausage: czz convert \[-[a-z]\b.+ <directives-file>\z/
      expect_specifically_invited_to :convert
    end
  end
end
