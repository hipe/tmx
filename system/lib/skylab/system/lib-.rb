module Skylab::System

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    define_singleton_method :memoize, Callback_::Memoize

    Basic = sidesys[ :Basic ]

    Brazen = sidesys[ :Brazen ]  # used in tests too

    File_utils = stdlib[ :FileUtils ]

    Human = sidesys[ :Human ]

    Open3 = stdlib[ :Open3 ]

    Parse_lib = sidesys[ :Parse ]

    Plugin = sidesys[ :Plugin ]

    Properties_stack_frame = -> *a do
      Brazen[]::Property::Stack.common_frame.call_via_arglist a
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
