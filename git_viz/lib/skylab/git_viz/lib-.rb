module Skylab::GitViz

  module Lib_  # :+[#ss-001]

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    define_singleton_method :_memoize, Callback_::Memoize

    gem = stdlib

    # ~ universe modules, sidesystem facilities and short procs all as procs

    Brazen = sidesys[ :Brazen ]

    Basic = sidesys[ :Basic ]  # was wall

    Basic_Set = -> * a do
      Basic[]::Set[ * a ]
    end

    Date_time = _memoize do
      require 'date'
      ::DateTime
    end

    Grit = _memoize do
      require 'grit'
      ::Grit
    end

    JSON = stdlib[ :JSON ]

    Listen = gem[ :Listen ]

    Local_normal_name_from_module = -> x do
      Callback_::Name.via_module( x ).as_lowercase_with_underscores_symbol
    end

    MD5 = _memoize do
      require 'digest/md5'
      ::Digest::MD5
    end

    _Hu = sidesys[ :Human ]

    NLP = -> do
      _Hu[]::NLP
    end

    Mock_system_lib = -> do
      Home_::Test_Lib_
    end

    Open3 = stdlib[ :Open3 ]

    Option_parser = _memoize do
      require 'optparse'
      ::OptionParser
    end

    oxford = Callback_::Oxford

    Oxford_or = oxford.curry[ ', ', '[none]', ' or ' ]

    Oxford_and = oxford.curry[ ', ', '[none]', ' and ' ]

    Plugin = sidesys[ :Plugin ]

    Power_scanner = -> * x_a do
      Callback_::Scn.multi_step.new_via_iambic x_a
    end

    Set = stdlib[ :Set ]

    Shellwords = stdlib[ :Shellwords ]

    Some_stderr_IO = -> do
      System[].IO.some_stderr_IO
    end

    Strange = -> x do
      Basic[]::String.via_mixed 120, x
    end

    String_scanner = _memoize do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib[].services
    end

    System_lib = sidesys[ :System ]

    # ZMQ = memo[ -> do require 'ffi-rzmq' ; ::ZMQ end ]
  end
end
# :#tombstone: "wall" (for rbx)
