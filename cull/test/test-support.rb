require 'skylab/cull'
require 'skylab/test_support'

module Skylab::Cull::TestSupport

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, The_use_method___
      tcc.include Instance_Methods___
    end

    cache = {}
    define_method :___lib do | sym |
      cache.fetch sym do
        x = TestSupport_.fancy_lookup sym, TS_
        cache[ sym ] = x
        x
      end
    end

  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

    The_use_method___ = -> sym do
      TS_.___lib( sym )[ self ]
    end

  module Instance_Methods___

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    # ~ paths for READ ONLY:

    def freshly_initted_path_
      dir :freshly_initted
    end

    def dir sym
      TS_::Fixtures::Directories[ sym ]
    end

    def file sym
      TS_::Fixtures::Files[ sym ]
    end

    # ~ mutable workspace methods

    def prepare_tmpdir_with_patch sym
      td = prepare_tmpdir
      td.patch_via_path TS_::Fixtures::Patches[ sym ]
      td
    end

    def prepare_tmpdir

      td = Home_.lib_.filesystem.tmpdir(
        :path, tmpdir_path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO )

      td.clear
    end

    def tmpdir_path

      ::File.join Home_.lib_.filesystem.tmpdir_path, 'culio'
    end

    # ~ assertion support

    def content_of_the_file td
      ::File.read( td.to_pathname.join( config_filename ).to_path )
    end

    def config_filename
      Config_filename___[]
    end

    # ~ #hook-outs for [br]

    def black_and_white_expression_agent_for_expect_event
      Home_::Brazen_::API.expression_agent_instance
    end

    def subject_API
      Home_::API
    end
  end

  Callback__ = ::Skylab::Callback

  Config_filename___ = Callback__.memoize do
    o = Home_::Models_::Survey
    ::File.join o::FILENAME_, o::CONFIG_FILENAME_
  end

  Expect_Event = -> test_context_class do
    Callback__.test_support::Expect_Event[ test_context_class ]
  end

  Callback__::Autoloader[ self,  ::File.dirname( __FILE__ ) ]

  DASH_ = '-'
  Home_ = ::Skylab::Cull
  NEWLINE_ = "\n"
  UNDERSCORE_ = '_'
  TS_ = self
end
