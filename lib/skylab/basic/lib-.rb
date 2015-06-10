module Skylab::Basic

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    Brazen = sidesys[ :Brazen ]

    Bundle_Directory = -> mod do
      MH__[]::Bundle::Directory[ mod ]
    end

    Bundle_Multiset = -> mod do
      MH__[]::Bundle::Multiset[ mod ]
    end

    CLI_lib = -> do
      HL__[]::CLI
    end

    Empty_string_scanner = -> do
      StringScanner__[].new ''
    end

    Enhancement_shell = -> a do
      MH__[]::Enhance::Shell.new a
    end

    Funcy_globful = -> x do
      MH__[].funcy_globful x
    end

    HL__ = sidesys[ :Headless ]

    Hu___ = sidesys[ :Human ]

    IO_lib = -> do
      System_lib__[]::IO
    end

    MH__ = sidesys[ :MetaHell ]

    NLP_EN = -> do
      Hu___[]::NLP::EN
    end

    NLP_EN_agent = -> do
      HL__[].expression_agent.NLP_EN_agent
    end

    Oxford_or = -> a do
      Callback_::Oxford_or[ a ]
    end

    Parse_lib = sidesys[ :Parse ]

    Scn_lib = -> do
      Callback_::Scn
    end

    Set = -> * a do
      Set__[].new( * a )
    end

    Set__ = stdlib[ :Set ]

    Some_stderr_IO = -> do
      System_lib__[]::IO.some_stderr_IO
    end

    Strange = -> x do  # looks better in expressions for this to be here
      Basic_::String.via_mixed x
    end

    String_IO = -> do
      StringIO__[].new
    end

    StringIO__ = stdlib[ :StringIO ]

    String_scanner = -> str do
      StringScanner__[].new str
    end

    StringScanner__ = Callback_.memoize do
      require 'strscan'
      ::StringScanner
    end

    System_lib__ = sidesys[ :System ]

    Test_support = sidesys[ :TestSupport ]

    Treetop = Callback_.memoize do

      require 'treetop'
      ::Treetop
    end
  end
end
