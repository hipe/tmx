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

  # -
    The_use_method___ = -> sym do
      TS_.___lib( sym )[ self ]
    end
  # -

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

    def prepare_tmpdir_with_patch_ sym
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

    # ~ retrofit

    def expect_not_OK_event_ sym

      em = expect_not_OK_event
      em.cached_event_value.to_event.terminal_channel_symbol.should eql sym
      em
    end

    def expect_event_ sym

      em = expect_event
      em.cached_event_value.to_event.terminal_channel_symbol.should eql sym
      em
    end

    def expect_OK_event_ sym

      em = expect_OK_event
      em.cached_event_value.to_event.terminal_channel_symbol.should eql sym
      em
    end

    # ~ #hook-outs for [br]

    def subject_API
      Home_::API
    end
  end

  # ==

  Home_ = ::Skylab::Cull

  Lazy_ = Home_::Lazy_

  Config_filename___ = Lazy_.call do
    o = Home_::Models_::Survey
    ::File.join o::FILENAME_, o::CONFIG_FILENAME_
  end

  Expect_Event = -> test_context_class do
    Common___.test_support::Expect_Emission[ test_context_class ]
  end

  Autoloader_ = Home_::Autoloader_

  Autoloader_[ self,  ::File.dirname( __FILE__ ) ]

  Common___ = ::Skylab::Common
  DASH_ = '-'
  NEWLINE_ = "\n"
  UNDERSCORE_ = '_'
  TS_ = self
end
