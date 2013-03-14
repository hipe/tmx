require_relative 'test-support'


module Skylab::Snag::TestSupport::CLI

  # has Quickie - try running this with just `ruby -w foo_spec.rb`

  describe "#{ Snag::CLI } - Core" do

    extend CLI_TestSupport

    acts = '\{node.*nodes.*numbers.*open.*todo.*\}'
    expecting_rx = %r{\AExpecting #{ acts }}i
    invite_rx = %r{\ATry sn0g -h for help\.$}i
    usage_rx = %r{\Ausage: sn0g #{ acts } \[opts\] \[args\]$}
    deeper_invite_rx = %r{\AFor help on a particular subcommand, try #{
      }sn0g <subcommand> -h\.$}i
    blank_line_rx = /\A\n\z/

    context "the CLI cannon (with the same memoized client!) - lvls 0 & 1 ui" do

      use_memoized_client

      it "0.0  (no args) - expecting / usage / invite" do
        client_invoke
        o expecting_rx
        o usage_rx
        o invite_rx
        o
      end

      it "1.2  (strange opt) - reason / expecting / invite" do
        client_invoke '-x'
        o( /\Ainvalid action.+-x/i )
        o expecting_rx
        o invite_rx
        o
      end

      it "1.4 (good opt) - usage / invite" do
        client_invoke '-h'
        o usage_rx
        o blank_line_rx
        o deeper_invite_rx
        o
      end
    end
  end
end
