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

    define_method :memoized_tmpdir_, ( -> do
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
  end

  # -- test library nodes

  Expect_Event = -> tcc do

    Callback_.test_support::Expect_Event[ tcc ]

    tcc.send(
      :define_method,
      :black_and_white_expression_agent_for_expect_event,
    ) do
      Home_.lib_.brazen::API.expression_agent_instance
    end
  end

  Expect_Line = -> tcc do
    TestSupport_::Expect_line[ tcc ]
  end

  # --

  Home_ = ::Skylab::System

  Callback_ = Home_::Callback_

  Callback_::Autoloader[ self, ::File.dirname( __FILE__ ) ]

  EMPTY_A_ = [].freeze
  EMPTY_S_ = Home_::EMPTY_S_
  NIL_ = Home_::NIL_
  TS_ = self
end

# (point of history - what used to be this node became [#br-xxx])
# (which is now [#pl-024] the "fancy lookup" algorithm)
