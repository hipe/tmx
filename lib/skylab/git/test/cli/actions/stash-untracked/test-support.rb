require_relative '../test-support'

module Skylab::Git::TestSupport::CLI::Actions::Stash_Untracked

  ::Skylab::Git::TestSupport::CLI::Actions[ self ]

  module CONSTANTS
    GSU = -> do
      Git::CLI::Actions::Stash_Untracked
    end
    WAZZLE = 'wazzle'.freeze
  end
  include CONSTANTS
  Git = Git ; GSU = GSU
  Headless = Headless
  TestSupport = TestSupport
  WAZZLE = WAZZLE

  module InstanceMethods

    # ~ hook-ins

    def do_debug= yes
      yes and @debug_IO ||= TestSupport::System.stderr
      super
    end

    attr_reader :debug_IO

    let :_CLI_client do
      _i, _o, _e = [ nil, * two_spy_group.to_a ]
      cli = Git::CLI::Actions::Stash_Untracked::CLI.new _i, _o, _e
      cli.program_name = WAZZLE
      cli
    end

    # ~ test-time environment configuration

    def with_popen3_out_as str  # we used to stub Open3 but it broke and sucked
      ctx = self
      _CLI_client.define_singleton_method :popen3_notify do |cmd_s, &p|
        ctx.last_popen3_command_string = cmd_s
        p[ nil, Git::Library_::StringIO.new( str ), ::StringIO.new( '' ) ]
      end
    end
    #
    attr_accessor :last_popen3_command_string


    # ~ test-time support

    def cd path, & p
      Git::Library_::FileUtils.cd path.to_s, & p
    end

    def workdir_pn  # #hookout
      Workdir_pn__[ -> do
        td = gsu_tmpdir
        td.exist? or td.prepare
        td.touch_r 'my-workdir/'
      end ]
    end

    Workdir_pn__ = -> do
      p = -> p_ do
        x = p_[] ; p = -> _ { x } ; x
      end
      -> p_ { p[ p_ ] }
    end.call

    def gsu_tmpdir
      GSU_Tmpdir__[ do_debug ]
    end
    #
    GSU_Tmpdir__ = -> do
      p = -> do_dbg do
        _tdpn = Headless::System.defaults.tmpdir_pathname.join 'gsu-xyzzy'
        _GSU_tmpdir = TestSupport::Tmpdir.new _tdpn.to_s
        if do_dbg
          _GSU_tmpdir.debug!
        end
        p = -> _ { _GSU_tmpdir } ; _GSU_tmpdir
      end
      -> do_dbg { p[ do_dbg ] }
    end.call


    def expect_succeeded
      expect_no_more_lines
      @result.should eql GSU[]::CLI::SUCCESS_EXITSTATUS
    end

  end
end
