require_relative 'test-support'

module Skylab::Git::TestSupport::CLI::Actions::Stash_Untracked::List__

  ::Skylab::Git::TestSupport::CLI::Actions::Stash_Untracked[ TS__ = self ]

  include Constants

  GSU = GSU ; OUT_I = OUT_I

  describe "[gi] CLI actions gsu list" do  # :+#no-quickie-because: `.stub`-ing

    extend TS__

    context "two files" do

      def prepare
        gsu_tmpdir.clear.touch_r %w(
          stashiz/alpha/herpus/derpus.txt
          stashiz/beta/whatever.txt ) ; nil
      end

      it "list the known stashes (API)" do
        prepare
        td = gsu_tmpdir
        o = GSU[]::API::Actions::List.new mock_client
        r = o.invoke stashes_path: td.join( 'stashiz' ), be_verbose: nil
        _act_s = contiguous_string_from_lines_on OUT_I
        expect_no_more_lines
        r.should eql true
      end

      let :mock_client do
        m = Mock_Client__.new
        m.stub :emit_payload_line do |line|
          two_spy_group[ OUT_I ].puts line
        end
        m
      end
      Mock_Client__ = ::Class.new

      -> do
        s = nil
        define_method :exp_s do
          s ||= <<-HERE.unindent
            alpha
            beta
          HERE
        end
      end.call

      def get_common_argv
        [ 'list', '-s', "#{ gsu_tmpdir }/stashiz" ]
      end

      context "when none" do
        def prepare
          gsu_tmpdir.clear.touch_r 'stashiz/'
        end

        it "yerp" do
          prepare
          invoke get_common_argv
          expect ERR_I, /\A\(while listing stash.+no stashes found in /
          expect_succeeded
        end
      end

      it "list the known stashes (CLI)" do
        prepare
        invoke get_common_argv
        _act_s = contiguous_string_from_lines_on OUT_I
        _act_s.should eql exp_s
        expect_succeeded
      end
    end
  end
end
