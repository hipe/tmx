require_relative '../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] CLI core" do

    extend TS_

    use :expect_my_CLI

    expecting_rx = %r{\Aexpecting <action>\z}i

    usage_rx = %r{\Ausage: sn0g <action> \[\.\.\]\n?\z}

    invite_rx = %r{\Ause 'sn0g -h' for help$}i

    deeper_invite_rx = %r{\Ause 'sn0g -h <action>' for help on that action.\n\z}

    context "the CLI canon (with the same memoized client!) - lvls 0 & 1 ui" do

      use_memoized_client

      it "0.0  (no args) - expecting / usage / invite" do

        invoke
        o expecting_rx
        o usage_rx
        o invite_rx
        o
      end

      it "1.2  (strange opt) - reason / invite" do

        invoke '-x'
        expect "invalid option: -x"
        o invite_rx
        o
      end

      it "1.3  (good arg) (ping)" do

        invoke 'ping'
        expect 'hello from snag.'
        expect_no_more_lines
        @exitstatus.should eql :hello_from_snag
      end

      it "1.4  (good opt) - usage / invite" do

        invoke '-h'

        on_stream :e
        o = flush_to_content_scanner

        o.expect_styled_line.should match usage_rx
        o.expect_nonblank_line
        o.expect_blank_line
        o.expect_header :actions

        o.advance_to_before_Nth_last_line 1
        o.expect_styled_line.should match deeper_invite_rx

        expect_succeeded
      end

      it "2.3x4H (good arg/good opt) (help postfix) (param API)", wip: true do
        invoke 'todo', '-h'
        c = output.class::Composite.of output.lines
        c.unique_stream_name_order_i_a.should eql %i( info )
        c.full_text.should be_include(
          'usage: sn0g todo [<action>] [<args> [..]]' )
        c.full_text.should be_include( 'sub-action help' )
        c.full_text.should be_include( 'EXPERIMENTAL' )
      end
    end

    context "'numbers' with", wip: true do

      with_invocation 'numbers'

      # with_default_expected_stream_name :pay #see

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
