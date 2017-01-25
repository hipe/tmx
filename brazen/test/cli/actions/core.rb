require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  module CLI::Actions

    class << self
      def [] tcc
        TS_.lib_( :CLI_behavior )[ tcc ]
        tcc.extend Module_Methods___
        tcc.include Instance_Methods___
        NIL_
      end
    end  # >>

    module Module_Methods___

    def with_max_num_dirs_ d
      __add_env_setting :MAX_NUM_DIRS, d ; nil
    end

    def __add_env_setting sym, x

      env_p_a_for_write.push( -> env do
        env[ "BRAZEN_#{ sym }" ] = x
      end )
      NIL
    end

    def env_p_a_for_write
      if ! env_p_a
        @env_p_a = _A_ = []
        define_method :prepare_env do |env|
          _A_.each { |p| p[ env ] }
        end
      end
      @env_p_a
    end

    attr_reader :env_p_a

    # ~

    def from_empty_directories_two_deep

        _working_directory_by do

          dir = ::File.join _tmpdir_path, 'empty-foo/empty-bar'

          if ! ::File.exist? dir
            _file_utils_controller.mkdir_p dir
          end

          dir
        end
    end

    def from_new_directory_one_deep

        _working_directory_by do

          dir = ::File.join _tmpdir_path, 'scratch-one'

          if ::File.exist? dir
            __blow_away dir
          end

          _file_utils_controller.mkdir dir

          dir
        end
    end

    def from_directory_with_already_a_file

        _working_directory_by do

          dir = ::File.join _tmpdir_path, 'with-one-empty-file'

          file = ::File.join dir, cfg_filename

          if ! ::File.exist? file

            if ! ::File.exist? dir
              _file_utils_controller.mkdir dir
            end

            _file_utils_controller.touch file
          end

          dir
        end
    end

      def _working_directory_by & p

        yes = true ; x = nil

        define_method :working_directory_for_expect_stdout_stderr do
          if yes
            yes = false
            x = instance_exec( & p )
          end
          x
        end
        NIL
      end
    end

    module Instance_Methods___

    def argv_prefix_for_expect_stdout_stderr
      self.class.sub_action_s_a
    end

    def prepare_subject_CLI_invocation invo
      env = {}
      prepare_env env
      invo.receive_environment env  # never use real life ::ENV !
        # see tombstone - used to CD
        NIL
    end

    def prepare_env _
        NIL
    end

    # ~ support above

      def __blow_away path

        td_path = _tmpdir_path

      if td_path == path[ 0, td_path.length ] && path.include?( '/brAzen/' )
        if do_debug
          debug_IO.puts "rm -rf #{ path }"
        end
          _file_utils_controller.remove_entry_secure path  # SCARY
      else
        self._SANITY
      end ; nil
      end

      def _working_directory
        NOTHING_
      end

      def _file_utils_controller
        Memoized_file_utils_controller__.call do
          Build_file_utils_controller__[ method( :do_debug ), debug_IO ]
        end
      end

      def _tmpdir_path
        Memoized_tmpdir_path___.call do
          Build_tmpdir_path___[ method( :do_debug ), debug_IO ]
        end
      end

    # ~ expectation support

    def expect_localized_invite_line
      expect :styled, localized_invite_line_rx
    end

    def expect_exitstatus_for_resource_not_found
      expect_exitstatus_for :resource_not_found
    end

    def ick x

      if x.respond_to? :ascii_only?
        x.inspect
      elsif x.respond_to? :bit_length
        x.inspect
      else
        self._COVER_ME
      end
    end

    def env s
      ::Regexp.escape "BRAZEN_#{ s.upcase.gsub DASH_, UNDERSCORE_ }"
    end

    def par s
      "(?:--|<)(?i:#{ ::Regexp.escape s })>?"
    end
    end

    inline_lazy = -> do  # dangerous
      yes = true ; x = nil
      -> & p do
        if yes
          yes = false
          x = p[]
        end
        x
      end
    end

    Memoized_tmpdir_path___ = inline_lazy[]

    Build_tmpdir_path___ = -> do_debug_p, debug_IO do

      _head = TestLib_::System_tmpdir_path[]
      dir = ::File.join _head, 'brAzen'

      if ! ::File.exist? dir

        _fuc = Memoized_file_utils_controller__.call do
          Build_file_utils_controller__[ do_debug_p, debug_IO ]
        end

        _fuc.mkdir dir
      end

      dir
    end

    Memoized_file_utils_controller__ = inline_lazy[]

    Build_file_utils_controller__ = -> do_debug_p, debug_IO do

      _cls = File_utils_class___[]
      _cls.new do_debug_p, debug_IO

    end

    # ==

    File_utils_class___ = Lazy_.call do

      require 'fileutils'

      class FileUtilsController____  # re-write of similar [#sy-011]

        include ::FileUtils

        def initialize do_debug_p, io
          @debug_IO = io
          @do_debug_proc = do_debug_p
        end

        _VERBOSE = { verbose: true }.freeze

        # ::FileUtils.collect_method( :verbose ).each do |meth_i|

        _THESE = %i( cd mkdir mkdir_p remove_entry_secure touch )

        _THESE.each do |m|

          define_method m do |*a, &p|

            _yes = @do_debug_proc[]
            if _yes

              h = ::Hash.try_convert a.last
              if h
                _h_ = h.dup.merge! _VERBOSE
                a[ -1 ] = _h_
              else
                a.push _VERBOSE
              end
            end

            super( * a, & p )
          end

          public m  # from private of parent module
        end

        def fu_output_message msg
          @debug_IO.puts msg
          NIL
        end

        self
      end
    end

    # ==

    DASH_ = '-'.freeze
    UNDERSCORE_ = '_'.freeze

    # ==
  end
end
