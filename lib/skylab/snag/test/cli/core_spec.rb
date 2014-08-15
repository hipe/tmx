require_relative 'test-support'

module Skylab::Snag::TestSupport::CLI

  describe "[sg] CLI core" do

    extend TS_

    acts = '\{node.*nodes.*numbers.*open.*todo.*\}'
    expecting_rx = %r{\AExpecting #{ acts }}i
    invite_rx = %r{\ATry sn0g -h for help\.$}i
    usage_rx = %r{\Ausage: sn0g #{ acts } \[opts\] \[args\]$}
    deeper_invite_rx = %r{\AFor help on a particular subcommand, try #{
      }sn0g <subcommand> -h\.$}i
    blank_line_rx = /\A\z/  # expects chomp to be used

    context "the CLI cannon (with the same memoized client!) - lvls 0 & 1 ui" do

      use_memoized_client

      it "0.0  (no args) - expecting / usage / invite" do
        invoke
        o expecting_rx
        o usage_rx
        o invite_rx
        o
      end

      it "1.2  (strange opt) - reason / expecting / invite" do
        invoke '-x'
        o( /\Ainvalid action.+-x/i )
        o expecting_rx
        o invite_rx
        o
      end

      it "1.3 (good arg) (ping)" do
        invoke 'ping'
        o 'hello from snag.'
        @result.should eql :hello_from_snag
      end

      it "1.4 (good opt) - usage / invite" do
        invoke '-h'
        o usage_rx
        o blank_line_rx
        o deeper_invite_rx
        o
      end

      it "2.3x4H (good arg/good opt) (help postfix) (param API)" do
        invoke 'todo', '-h'
        c = output.class::Composite.of output.lines
        c.unique_stream_name_order_i_a.should eql %i( info )
        c.full_text.should be_include(
          'usage: sn0g todo [<action>] [<args> [..]]' )
        c.full_text.should be_include( 'sub-action help' )
        c.full_text.should be_include( 'melt is insanity' )
      end
    end
  end
end
