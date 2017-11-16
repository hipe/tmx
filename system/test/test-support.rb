require 'skylab/system'
require 'skylab/test_support'

module Skylab::System::TestSupport

  class << self

    def [] tcc  # "test context class"

      tcc.extend ModuleMethods_
      tcc.include InstanceMethods___ ; nil
    end

    def tmpdir_path_
      @___tmpdir_path ||= ___assemble_tmpdir_path
    end

    def ___assemble_tmpdir_path
      _path = Home_.services.filesystem.tmpdir_path
      ::File.join _path, '[sy]'
    end
  end  # >>

  cache = {}
  define_singleton_method :lib_ do | sym |
    cache.fetch sym do
      x = TestSupport_.fancy_lookup sym, TS_
      cache[ sym ] = x
      x
    end
  end

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  # -- functions that are also used in method definitions

  Home_ = ::Skylab::System
  Common_ = Home_::Common_
  Lazy_ = Common_::Lazy

  Fixture_file_ = -> tail do
    ::File.join TS_.dir_path, 'fixture-files', tail
  end

  # --

  module ModuleMethods_

    def use sym
      TS_.lib_( sym )[ self ]
    end

    define_method :memoize, & TestSupport_::MEMOIZE

    define_method :dangerous_memoize, & TestSupport_::DANGEROUS_MEMOIZE
  end

  module InstanceMethods___

    def want_these_lines_in_array_ act_s_a, & p

      TestSupport_::Want_Line::Want_these_lines_in_array.call(
        act_s_a, p, self )
    end

    def expression_agent_of_API_classic_
      Home_.lib_.brazen::API.expression_agent_instance
    end

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    define_method :memoized_tmpdir_, ( -> do  # (see also #here)
      o = nil
      -> do
        if o
          o.for self
        else
          o = Home_::Filesystem::Tmpdir.memoizer_for self, 'sy-xyzizzy'
          o.instance
        end
      end
    end ).call

    define_method :the_no_ent_directory_, ( Lazy_.call do
      ::File.join TS_.dir_path, 'no-ent'
    end )

    def fu_
      Home_.lib_.file_utils
    end

    def tmpdir_path_for_memoized_tmpdir
      real_filesystem_.tmpdir_path
    end

    def real_filesystem_
      services_.filesystem
    end

    def services_
      Home_.services
    end

    def subject_API_value_of_failure
      FALSE
    end

    def listener_
      event_log.handle_event_selectively
    end

    define_method :fixture_file_, Fixture_file_

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  # -- test library nodes

  Want_Event = -> tcc do
    Common_.test_support::Want_Emission[ tcc ]
  end

  Want_Line = -> tcc do
    TestSupport_::Want_line[ tcc ]
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  The_Method_Called_Let = -> tcc do
    TestSupport_::Let[ tcc ]
  end

  # -- functions

  Tmpdir_ = Lazy_.call do
    Tmpdir_controller_[].path
  end

  Tmpdir_controller_ = Lazy_.call do

    # (use memoized_tmpdir_ if you can, this if you can't (#here))

    _tmpdir = Home_.services.defaults.dev_tmpdir_path

    _path = ::File.join _tmpdir, 'sy-xyzizzy-g'

    Home_::Filesystem::Tmpdir.with(
      :path, _path,
      :max_mkdirs, 2,  # one universe wide, one for the sidesystem
    )
  end

  # --

  Common_::Autoloader[ self, ::File.dirname( __FILE__ ) ]

  Basic_ = Home_::Basic_
  EMPTY_A_ = Home_::EMPTY_A_
  EMPTY_S_ = Home_::EMPTY_S_
  NIL_ = Home_::NIL_
  NIL = nil  # open [#sli-016.C]
    FALSE = false ; TRUE = true
  NOTHING_ = Home_::NOTHING_
  TS_ = self
end
# (point of history - what used to be this node became [#br-xxx])
# (which is now [#pl-024] the "fancy lookup" algorithm)
