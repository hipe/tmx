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
        c.full_text.should be_include( 'EXPERIMENTAL' )
      end
    end

    context "'numbers' with" do

      with_invocation 'numbers'

      with_default_expected_stream_name :pay

      context "a manifest with two good lines" do
        with_manifest <<-O.unindent
          [#001] foo
          [#3] bar
        O
        it "ok" do
          setup_tmpdir_read_only
          invoke
          o '[#001]'
          o '[#3]'
          o :info, found_N_valid_of_N_total( 2, 2 )
          expect_succeeded
        end
      end

      context "a manifest with no lines" do
        with_manifest TestSupport_::EMPTY_S_
        it "ok." do
          setup_tmpdir_read_only
          invoke
          o :info, found_N_valid_of_N_total( 0, 0 )
          expect_succeeded
        end
      end

      context "no manifest" do
        with_tmpdir do |o|
          o.clear
        end
        it "ok. (note the event is SIGNED TWICE - by both CLI and API!)" do
          setup_tmpdir_read_only
          with_API_max_num_dirs 1
          invoke
          expect :info,
            %r(\Afailed to numbers because failed to find manifest file - #{
              }"[^"]+" not found in \.\z)i
          expect :info, %r(\Asn0g numbers -h might have more info)i
          expect_failed
        end
      end

      context "a manifest with two good one bad" do
        with_manifest <<-O.unindent
          [#01]
          fml
          [#99]
        O
        it "ok." do
          setup_tmpdir_read_only
          invoke
          o '[#01]'
          o :info, %r(\bexpecting identifier near fml \(\./doc/issues\.md:2\))i
          o '[#99]'
          o :info, found_N_valid_of_N_total( 2, 3 )
          expect_succeeded
        end
      end

      def found_N_valid_of_N_total d, d_
        "found #{ d } valid of #{ d_ } total nodes."
      end
    end
  end
end
