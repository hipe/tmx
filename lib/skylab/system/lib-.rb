module Skylab::System

  module Lib_

    sidesys, stdlib,  = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    define_singleton_method :memoize, Callback_::Memoize

    Basic = sidesys[ :Basic ]

    Bzn__ = sidesys[ :Brazen ]  # used in tests too

    Entity = -> * a, & p do
      if a.length.zero? && ! p
        Bzn__[]::Entity
      else
        Bzn__[]::Entity.call_via_arglist a, & p
      end
    end

    File_utils = stdlib[ :FileUtils ]

    Ivars_with_procs_as_methods = -> * a do
      MH__[]::Ivars_with_Procs_as_Methods.call_via_arglist a
    end

    MH__ = sidesys[ :MetaHell ]

    Open3 = stdlib[ :Open3 ]

    Parse_lib = -> do
      MH__[]::Parse
    end

    Properties_stack_frame = -> *a do
      Bzn__[].properties_stack.common_frame.call_via_arglist a
    end

    Shellwords = stdlib[ :Shellwords ]

    String_scanner = -> do
      p = -> s do
        require 'strscan'
        p = -> s_ do
          ::StringScanner.new s_
        end
        p[ s ]
      end
      -> s do
        p[ s ]
      end
    end.call

    String_IO = stdlib[ :StringIO ]

    Tmpdir = memoize do
      require 'tmpdir'
      ::Dir.tmpdir
    end
  end
end
