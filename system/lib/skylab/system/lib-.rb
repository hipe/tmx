module Skylab::System

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    define_singleton_method :_memoize, Callback_::Memoize

    Autonomous_component_system = sidesys[ :Autonomous_Component_System ]

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]  # used in tests too
    Fields = sidesys[ :Fields ]

    File_utils = stdlib[ :FileUtils ]

    Human = sidesys[ :Human ]

    Open3 = stdlib[ :Open3 ]

    Parse_lib = sidesys[ :Parse ]
    Plugin = sidesys[ :Plugin ]

    Properties_stack_frame = -> *a do
      Brazen[]::Property::Stack.common_frame.call_via_arglist a
    end

    Shellwords = stdlib[ :Shellwords ]

    string_scanner_class = _memoize do
      require 'strscan'
      ::StringScanner
    end

    String_scanner = -> s do
      string_scanner_class[].new s
    end

    String_IO = stdlib[ :StringIO ]

    Tmpdir = _memoize do
      require 'tmpdir'
      ::Dir.tmpdir
    end
  end
end
