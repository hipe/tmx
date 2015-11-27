require 'skylab/code_molester'
require 'skylab/test_support'

module Skylab::CodeMolester::TestSupport

  class << self
    def [] tcc
      tcc.extend Module_Methods___
      tcc.include Instance_Methods___
      NIL_
    end
  end  # >>

  module Module_Methods___

    cache = {}
    define_method :use do | sym |
      _ = cache.fetch sym do
        x = TestSupport_.fancy_lookup sym, TS_
        cache[ sym ] = x
        x
      end
      _[ self ]
    end

    def share_subject sym, & p  # a different branding of DANGEROUS #[#ts-042]

      yes = true ; x = nil
      define_method sym do
        if yes
          yes = false
          x = instance_exec( & p )
        end
        x
      end
    end

    alias_method :dangerous_memoize, :share_subject

    def memoize sym, & p
      yes = true ; x = nil
      define_method sym do
        if yes
          yes = false
          x = p[]
        end
        x
      end
    end
  end

  Home_ = ::Skylab::CodeMolester
  Callback__ = Home_::Callback_

  Callback__::Autoloader[ self, ::File.dirname( __FILE__ ) ]

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.enable_kernel_describe

  memoized_tmpdir_for = nil
  make_memoizer = -> do

    $stderr.puts "(hi)"

    make_memoizer = nil

    _path = ::File.join Home_.lib_.system.filesystem.tmpdir_path, 'co-mo'

    memoized_tmpdir_for = TestSupport_.tmpdir.new_with(
      :max_mkdirs, 2,
      :path, _path

    ).to_memoizer
    NIL_
  end

  Tmpdir = -> tcc do

    tcc.send :define_method, :tmpdir do

      if make_memoizer
        make_memoizer[]
      end

      memoized_tmpdir_for[ self ]
    end
  end

  module Instance_Methods___

    def debug!
      @do_debug = true ; nil
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  module TestLib_

    Bzn = -> do
      Home_::Lib_::Brazen[]
    end

    Expect_line = -> do
      TestSupport_::Expect_line
    end
  end

  EMPTY_S_ = Home_::EMPTY_S_
  NIL_ = nil
  TS_ = self
end
# #tombstone: TestSupport_::Quickie.do_not_invoke! (in deleted file)
