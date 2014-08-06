require_relative '../test-support'

module Skylab::Brazen::TestSupport::CLI::Actions

  ::Skylab::Brazen::TestSupport::CLI[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Brazen_ = Brazen_

  module ModuleMethods

    def with_sub_action * s_a
      s_a.freeze
      define_method :sub_action_s_a do s_a end
      _RX_ = /\Ause '?bzn #{ s_a * ' ' } -h'? for help\z/
      define_method :localized_invite_line_rx do _RX_ end
    end

    def with_max_num_dirs d
      add_env_setting :MAX_NUM_DIRS, d ; nil
    end

    def add_env_setting i, x
      env_p_a_for_write.push -> env { env[ "BRAZEN_#{ i }" ] = x } ; nil
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
      from_directory do
        pn = tmpdir.join 'empty-foo/empty-bar'
        if ! pn.exist?
          file_utils.mkdir_p pn.to_path
        end
        pn.to_path
      end
    end

    def from_directory & p
      define_method :from_directory, & p ; nil
    end
  end

  module InstanceMethods

    def prepare_invocation
      env = {}
      prepare_env env
      if env.length.nonzero?
        @invocation.environment = env
      end

      path = from_directory
      if path
        file_utils.cd path
      end
    end

    def prepare_env _
    end

    # ~ support above

    def from_directory
    end

    def file_utils
      @fu ||= TestLib_::File_utils[ -> { do_debug }, debug_IO ]
    end

    def tmpdir
      @td ||= TestLib_::Tempdir_pathname[ debug_IO ]
    end

    # ~ business

    def filename
      Brazen_::Models_::Workspace::CONFIG_FILENAME__
    end

    # ~ expectation support

    def expect_localized_invite_line
      expect :styled, localized_invite_line_rx
    end

    def ick s
      "'#{ ::Regexp.escape s }'"
    end

    def env s
      ::Regexp.escape "BRAZEN_#{ s.upcase.gsub DASH_, UNDERSCORE_ }"
    end

    def par s
      "(?:--|<)(?i:#{ ::Regexp.escape s })>?"
    end
  end

  DASH_ = '-'.freeze ; UNDERSCORE_ = '_'.freeze

  module TestLib_
    monadic_memoize = -> p do
      p_ = -> x do
        x_ = p[ x ] ; p_ = -> _ { x_ } ; x_
      end
      -> x { p_[ x ] }
    end
    memoize = -> p do
      p_ = -> do
        x = p[] ; p_ = -> { x } ; x
      end
      -> { p_[] }
    end
    File_utils = -> do_debug_proc, debug_IO do
      File_utils_class[].new do_debug_proc, debug_IO
    end
    File_utils_class = memoize[ -> do
      require 'fileutils'
      class FU_Agent__  # re-write of similar [#hl-157]
        include ::FileUtils
        def initialize do_debug_proc, io
          @do_debug_p = do_debug_proc
          @io = io
        end
        _VERBOSE_ = { verbose: true }.freeze
        [ :cd, :mkdir, :mkdir_p ].each do |meth_i|
        # ::FileUtils.collect_method( :verbose ).each do |meth_i|
          public ( define_method meth_i do | *a, &p |
            if @do_debug_p[]
              if (( existing = ::Hash.try_convert a.last ))
                a[ -1 ] = existing.dup.merge! _VERBOSE_
              else
                a.push _VERBOSE_
              end
            end
            super( * a, & p )
          end )
        end
        def fu_output_message msg
          @io.puts msg ; nil
        end
        self
      end
    end ]
    Tempdir_pathname = monadic_memoize[ -> io do
      require 'tmpdir'
      pn = ::Pathname.new "#{ ::Dir.tmpdir }/brAzen"
      if ! pn.exist?
        File_utils[ io ].mkdir pn.to_path
      end
      pn
    end ]
  end
end
