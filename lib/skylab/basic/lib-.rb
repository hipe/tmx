module Skylab::Basic

  module Lib_  # :+[#su-001]

    memo, sidesys, stdlib = Autoloader_.at :memoize,
      :build_require_sidesystem_proc, :build_require_stdlib_proc

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

    Entity = -> * a, & edit_p do
      if a.length.nonzero? || edit_p
        Brazen[]::Entity.call_via_arglist a, & edit_p
      else
        Brazen[]::Entity
      end
    end

    Funcy_globful = -> x do
      MH__[].funcy_globful x
    end

    HL__ = sidesys[ :Headless ]

    IO_lib = -> do
      HL__[]::IO
    end

    Ivars_with_procs_as_methods = -> * a do
      MH__[]::Ivars_with_Procs_as_Methods.call_via_arglist a
    end

    Memoize = -> x do
      Callback_.memoize[ x ]
    end

    MH__ = sidesys[ :MetaHell ]

    NLP_EN_agent = -> do
      HL__[].expression_agent.NLP_EN_agent
    end

    Oxford_or = -> a do
      Callback_::Oxford_or[ a ]
    end

    Pool = -> x do
      MH__[]::Pool.enhance x
    end

    Scn_lib = -> do
      Callback_::Scn
    end

    Set = -> * a do
      Set__[].new( * a )
    end

    Set__ = stdlib[ :Set ]

    Some_stderr_IO = -> do
      HL__[]::System::IO.some_stderr_IO
    end

    Strange = -> x do
      MH__[].strange x
    end

    String_IO = -> do
      StringIO__[].new
    end

    StringIO__ = stdlib[ :StringIO ]

    String_scanner = -> str do
      StringScanner__[].new str
    end

    StringScanner__ = memo[ -> do require 'strscan' ; ::StringScanner end ]
  end
end
