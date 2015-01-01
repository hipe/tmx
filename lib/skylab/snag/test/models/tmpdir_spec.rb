require_relative 'test-support'

module Skylab::Snag::TestSupport::Models::TD__

  ::Skylab::Snag::TestSupport::Models[ TS__ = self ]

  include Constants ; extend TestSupport_::Quickie

  describe "[sg] models tmpdir" do  # location of this file is intentional

    extend TS__

    with_tmpdir do |o|
      o.clear.mkdir 'an-emtpy-dir'
    end

    context "in an empty directory in which it is OK to create" do

      let :tmpdir_pathname do
        tmpdir.join 'foo-zizzle'
      end

      it "will create when creating is OK to do." do
        setup_tmpdir_if_necessary
        subject
        @err_ev_a.length.should be_zero
        @FU_msg_s_a.length.should eql 1
        @FU_msg_s_a.first.should match %r(\Amkdir .+/foo-zizzle\z)
        @result.basename.to_path.should eql 'foo-zizzle'
      end
    end

    context "in an empty directory but with a request path too deep" do

      let :tmpdir_pathname do
        tmpdir.join 'fip-zazzle/crunk-nizzle'
      end

      it "will not create because it's too deep" do
        setup_tmpdir_if_necessary
        subject
        @FU_msg_s_a.length.should be_zero
        @err_ev_a.length.should eql 1
        ev = @err_ev_a.shift
        ev.terminal_channel_i.should eql :directory_must_exist
        ev.render_all_lines_into_under y=[], Snag_::API::EXPRESSION_AGENT
        y.first.should match %r(\Awon't create more than one directory\. #{
         }Parent directory of our tmpdir \(crunk-nizzle\) must exist: #{
          }fip-zazzle\z)
        @result.should be_nil
      end
    end

    def subject
      @result = Snag_::Models::Manifest::Tmpdir_produce__[ * defaults ]
    end

    def defaults
      [ :is_dry_run, false,
        :file_utils, file_utils_spy,
        :delegate, error_event_delegate,
        :tmpdir_pathname, tmpdir_pathname ]
    end

    let :error_event_delegate do
      @err_ev_a = []
      EE_L__.new do |ev|
        if do_debug
          debug_IO.puts "got error event ('#{ ev.terminal_channel_i }')"
        end
        @err_ev_a.push ev ; nil
      end
    end

    def file_utils_spy
      @file_utils_spy ||= bld_FU_spy
    end

    def bld_FU_spy
      @FU_msg_s_a = []
      Snag_.lib_.FUC.new do |msg|
        if do_debug
          debug_IO.puts "got FU msg: #{ msg }"
        end
        @FU_msg_s_a.push msg
      end
    end

    class EE_L__
      def initialize & p
        @p = p
      end
      def receive_error_event ev
        @p[ ev ]
      end
    end
  end
end
