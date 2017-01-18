module Skylab::Basic

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    Autonomous_component_system = sidesys[ :Autonomous_Component_System ]

    Brazen = sidesys[ :Brazen ]

    Bundle_Directory = -> mod do
      Plugin[]::Bundle::Directory[ mod ]
    end

    Bundle_Multiset = -> mod do
      Plugin[]::Bundle::Multiset[ mod ]
    end

    Empty_string_scanner = -> do
      StringScanner__[].new ''
    end

    Enhancement_shell = -> a do
      Plugin[]::Bundle::Enhance::Shell.new a
    end

    Fields = sidesys[ :Fields ]

    Human = sidesys[ :Human ]

    IO_lib = -> do
      System_lib__[]::IO
    end

    NLP_EN = -> do
      Human[]::NLP::EN
    end

    Oxford_or = -> a do
      Common_::Oxford_or[ a ]
    end

    Parse_lib = sidesys[ :Parse ]

    Pathname = stdlib[ :Pathname ]

    Plugin = sidesys[ :Plugin ]

    Set = -> * a do
      Set__[].new( * a )
    end

    Set__ = stdlib[ :Set ]

    Some_stderr_IO = -> do
      System_lib__[]::IO.some_stderr_IO
    end

    Strange = -> x do  # looks better in expressions for this to be here
      Home_::String.via_mixed x
    end

    String_IO = -> do
      StringIO__[].new
    end

    StringIO__ = stdlib[ :StringIO ]

    String_scanner = -> str do
      StringScanner__[].new str
    end

    StringScanner__ = Common_.memoize do
      require 'strscan'
      ::StringScanner
    end

    System_lib__ = sidesys[ :System ]

    Test_support = sidesys[ :TestSupport ]

    Time = stdlib[ :Time ]

    Treetop = Common_.memoize do

      require 'treetop'
      ::Treetop
    end
  end
end
