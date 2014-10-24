module Skylab::Basic

  module Lib_  # :+[#su-001]

    memo, sidesys, stdlib = Autoloader_.at :memoize,
      :build_require_sidesystem_proc, :build_require_stdlib_proc

    Bzn_ = sidesys[ :Brazen ]

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

    Entity = -> * x_a, & p do
      p and x_a.push p
      if x_a.length.nonzero?
        Bzn_[]::Entity.via_arglist x_a
      else
        Bzn_[]::Entity
      end
    end

    Event = -> do
      Bzn_[].event
    end

    Funcy_globful = -> x do
      MH__[].funcy_globful x
    end

    HL__ = sidesys[ :Headless ]

    Iambic_parameters = -> * i_a do
      HL__[]::API::Iambic_parameters[ * i_a ]
    end

    IO_lib = -> do
      HL__[]::IO
    end

    Ivars_with_procs_as_methods = -> * a do
      MH__[]::Ivars_with_Procs_as_Methods.via_arglist a
    end

    Memoize = -> x do
      Callback_.memoize[ x ]
    end

    MH__ = sidesys[ :MetaHell ]

    NLP_EN_agent = -> do
      HL__[].expression_agent.NLP_EN_agent
    end

    Old_box_lib = -> do
      MH__[]::Formal::Box
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
