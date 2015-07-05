module Skylab::Git::TestSupport

  module Models::Stow::Support

    def self.[] tcc

      Callback_.test_support::Expect_event[ tcc ]
      tcc.include Instance_Methods___
    end

    module Instance_Methods___

      define_method :git_ls_files_others_, ( -> do
        a = %w( git ls-files --others --exclude-standard )
        -> do
          a
        end
      end ).call

      define_method :stashiz_path_, ( Callback_.memoize do

        ::File.join Fixture_trees_[], 'stashiz'
      end )

      def no_ent_path_
        TestSupport_::Data::Universal_Fixtures[ :not_here ]
      end

      def empty_dir_
        TestSupport_::Data::Universal_Fixtures[ :empty_esque_directory ]
      end

      def subject_API
        Home_::API
      end

      def mock_system_conduit_where_ chdir, cmd, & three_p

        sy = Mock_System___.new
        sy._add_entry chdir, cmd, & three_p
        sy
      end

      define_method :memoized_tmpdir_, -> do

        td = nil  # :+#nasty_OCD_memoize

        -> do

          if td

            yes = do_debug
            yes_ = td.be_verbose

            if yes
              if ! yes_
                td = td.new_with :debug_IO, debug_IO, :be_verbose, true
              end
            elsif yes_ && ! yes
              td = td.new_with :be_verbose, false
            end
          else

            _path = real_filesystem_.tmpdir_pathname.join 'gi-xyzzy'

            td = TestSupport_.tmpdir.new_with(
              :path, _path,
              :be_verbose, do_debug,
              :debug_IO, debug_IO )
          end

          td
        end
      end.call

      def real_filesystem_
        Home_.lib_.system.filesystem
      end

      def real_system_conduit_
        Home_.lib_.open_3
      end

      def dirs_in_ path
        Callback_::Stream.via_nonsparse_array(
          `cd #{ path } && find . -type d -mindepth 1`.split NEWLINE_ )
      end

      def files_in_ path
        Callback_::Stream.via_nonsparse_array(
          `cd #{ path } && find . -type f`.split NEWLINE_ )
      end
    end

    class Mock_System___  # stay close to [#gv-007]

      def initialize

        @_h = {}
      end

      def popen3 * cmd_s_a, h

        block_given? and raise ::ArgumentError  # no

        _bx = @_h.fetch h.fetch :chdir

        _rslt = _bx.fetch cmd_s_a

        _rslt.produce
      end

      def _add_entry chdir, cmd_s_a, & three_p

        _bx = @_h.fetch chdir do
          @_h[ chdir ] = Callback_::Box.new
        end

        _bx.add cmd_s_a, Mock_Sys_Result___.new( & three_p )

        NIL_
      end
    end

    class Mock_Sys_Result___

      def initialize & three_p
        @_three_p = three_p
      end

      def produce

        sout_a = [] ; serr_a = []
        d = @_three_p[ :_nothing_, sout_a, serr_a ]

        sout_st = Callback_::Stream.via_nonsparse_array sout_a
        serr_st = Callback_::Stream.via_nonsparse_array serr_a
        thread = Mock_Thread___.new d

        [ :_dont_, sout_st, serr_st, thread ]
      end
    end

    class Mock_Thread___

      attr_reader :value

      def initialize d
        @value = Mock_Thread_Value___.new d
      end
    end

    Mock_Thread_Value___ = ::Struct.new :exitstatus

    # ~ hook-ins

    if false


    # ~ test-time support

    def gsu_tmpdir
      GSU_Tmpdir__[ do_debug ]
    end
    #
    GSU_Tmpdir__ = -> do

      p = -> do_dbg do

        _tdpn = TestLib_::Tmpdir_pathname[].join 'gsu-xyzzy'

        _GSU_tmpdir = TestLib_::Tmpdir[].new_with(
          :path, _tdpn.to_s,
          :max_mkdirs, 2
        )

        if do_dbg
          _GSU_tmpdir.debug!
        end

        p = -> _ { _GSU_tmpdir } ; _GSU_tmpdir

      end

      -> do_dbg do
        p[ do_dbg ]
      end

    end.call
    end

  end
end
