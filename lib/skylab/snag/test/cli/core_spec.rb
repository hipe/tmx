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


    it "THE CLI CANNON - LVL 0 and LVL 1 UI" do

      client_invoke               #   0 - expecting / invite
      o expecting_rx
      o invite_rx
      o
                                  # 1.1 SKIP - this dumbly does list


      client_invoke '-x'          # 1.2 - same as 0.0
      o expecting_rx
      o invite_rx
      o
                                  # 1.3 SKIP - this would be a good command

      client_invoke '-h'          # 1.4 GOOD OPT - usage / invite
      o usage_rx
      o deeper_invite_rx
      o


    end
  end
end
