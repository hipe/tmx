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
        x = TestSupport_.fancy_lookup sym, These___
        cache[ sym ] = x
        x
      end
    end

  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  # -
    The_use_method___ = -> sym do
      TS_.___lib( sym )[ self ]
    end
  # -

  module Instance_Methods___

    # -- assertion support (newer)

    def want_these_lines_in_array_with_trailing_newlines_ a, & p
      TestSupport_::Want_Line::Want_these_lines_in_array_with_trailing_newlines[ a, p, self ]
    end

    def want_these_lines_in_array_ a, & p
      TestSupport_::Want_these_lines_in_array[ a, p, self ]
    end

    # ~( during legacy use
    def black_and_white_expression_agent_for_want_emission
      _this_expag_TS
    end

    def expression_agent_for_want_emission
      _this_expag_TS
    end
    # ~)

    def _this_expag_TS
      # (legacy tests still use the default. we want newer tests to look natural)
      Home_::Zerk_lib_[]::No_deps[]::API_InterfaceExpressionAgent.instance
    end

    # ~ paths for READ ONLY:

    def freshly_initted_path_
      fixture_directory_ :freshly_initted
    end

    def fixture_directory_ sym
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

      _td = Home_.lib_.system_lib::Filesystem::Tmpdir.with(
        :path, tmpdir_path,
        :be_verbose, do_debug,
        :debug_IO, debug_IO,
      )

      _td.clear
    end

    def tmpdir_path

      ::File.join Home_.lib_.system.filesystem.tmpdir_path, 'culio'
    end

    # ~ assertion support

    def content_via_path_ path
      _path_ = ::Fie.join path, config_filename
      ::File.read _path_
    end

    def config_filename
      Config_filename___[]
    end

    # ~ retrofit

    def want_not_OK_event_ sym

      em = want_not_OK_event
      em.cached_event_value.to_event.terminal_channel_symbol.should eql sym
      em
    end

    def want_event_ sym

      em = want_event
      em.cached_event_value.to_event.terminal_channel_symbol.should eql sym
      em
    end

    def want_OK_event_ sym

      em = want_OK_event
      em.cached_event_value.to_event.terminal_channel_symbol.should eql sym
      em
    end

    # ~ #hook-outs for [br]

    def subject_API_value_of_failure
      NIL
    end

    def subject_API
      Home_::API
    end

    # -- standard

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  # ==

  module These___

    # tcc = test context class

    Want_Event = -> tcc do
      Common___.test_support::Want_Emission[ tcc ]
    end

    Memoizer_Methods = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end
  end

  # ==

  Home_ = ::Skylab::Cull

  Lazy_ = Home_::Lazy_

  Config_filename___ = Lazy_.call do
    o = Home_::Models_::Survey
    ::File.join o::FILENAME_, o::CONFIG_FILENAME_
  end

  Autoloader_ = Home_::Autoloader_

  Autoloader_[ self,  ::File.dirname( __FILE__ ) ]

  Common___ = ::Skylab::Common
  DASH_ = Home_::DASH_
  NEWLINE_ = "\n"
  NIL = nil  # open [#sli-016.C]
  UNDERSCORE_ = Home_::UNDERSCORE_
  TS_ = self
end
