require 'skylab/system'
require 'skylab/test_support'

module Skylab::System::TestSupport

  class << self

    def [] tcc  # "test context class"

      tcc.extend Module_Methods__
      tcc.include Instance_Methods__ ; nil
    end

    def mocks
      TS_::MOCKS
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

  extend TestSupport_::Quickie

  module Module_Methods__

    def use sym
      TS_.lib_( sym )[ self ]
    end

    define_method :memoize, & TestSupport_::MEMOIZE

    define_method :dangerous_memoize, & TestSupport_::DANGEROUS_MEMOIZE
  end

  module Instance_Methods__

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    define_method :memoized_tmpdir_, ( -> do  # (see also #here)
      o = nil
      -> do
        if o
          o.for self
        else
          o = TestSupport_.tmpdir.memoizer_for self, 'sy-xyzizzy'
          o.instance
        end
      end
    end ).call

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

    def handle_event_selectively_
      event_log.handle_event_selectively
    end
  end

  # -- test library nodes

  Expect_Event = -> tcc do
    Common_.test_support::Expect_Event[ tcc ]
  end

  Expect_Line = -> tcc do
    TestSupport_::Expect_line[ tcc ]
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  The_Method_Called_Let = -> tcc do
    TestSupport_::Let[ tcc ]
  end

  # -- functions

  Home_ = ::Skylab::System
  Common_ = Home_::Common_
  Lazy_ = Common_::Lazy

  Tmpdir_ = Lazy_.call do
    Tmpdir_controller_[].path
  end

  Tmpdir_controller_ = Lazy_.call do

    # (use memoized_tmpdir_ if you can, this if you can't (#here))

    svcs = Home_.services
    _tmpdir = svcs.defaults.dev_tmpdir_path
    _path = ::File.join _tmpdir, 'sy-xyzizzy-g'

    svcs.filesystem.tmpdir(
      :path, _path,
      :max_mkdirs, 2,  # one universe wide, one for the sidesystem
    )
  end

  # --

  Common_::Autoloader[ self, ::File.dirname( __FILE__ ) ]

  EMPTY_A_ = Home_::EMPTY_A_
  EMPTY_S_ = Home_::EMPTY_S_
  NIL_ = Home_::NIL_
  TS_ = self
end

# (point of history - what used to be this node became [#br-xxx])
# (which is now [#pl-024] the "fancy lookup" algorithm)
