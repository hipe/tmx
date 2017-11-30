require_relative 'test-support'

module Skylab::CSS_Convert::TestSupport

  describe "[cssc] CLI integration" do

    TS_[ self ]
    use :my_CLI_expectations

    it "with no args, gives warm, inviting message" do

      invoke
      want :styled, :e, 'expecting <action>'
      want_usaged_and_invited
    end

    it "with no args to action, gives helpful message" do

      invoke 'convert'
      want :styled, :e, "expecting: <directives-file>"
      _want_specific_usaged_and_invited
    end

    it "with too many args, should give friendly, " <<
      "not overbearing emotional support" do

      invoke 'convert', 'alpha', 'beta'
      want :e, "unexpected argument \"beta\""
      _want_specific_usaged_and_invited
    end

    it "should whine about file not found" do

      _path = fixture_path_ 'not-there.txt'
      invoke 'convert', _path
      want :e, /\Afailed because no such file or directory - .+\/fixture-files\/not-there\.txt\z/i

      want_specific_invite_line_to :convert
      want_no_more_lines
      expect( @exitstatus ).to eql Home_::Brazen_::API.exit_statii.fetch :resource_not_found
    end

    it "[tmx] integration", TMX_CLI_integration: true do

      Home_::Autoloader_.require_sidesystem :TMX

      cli = ::Skylab::TMX.test_support.begin_CLI_expectation_client

      cli.invoke 'css-convert', 'convert', '--ping'

      cli.want_on_stderr "hello from css convert."

      cli.want_succeed_under self
    end

    def _want_specific_usaged_and_invited

      want :styled, :e, /\Ausage: czz convert \[-[a-z]\b.+ <directives-file>\z/
      want_specifically_invited_to :convert
    end
  end
end
