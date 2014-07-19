module Skylab::Basic

  module Lib_  # :+[#su-001]

    memo, sidesys, stdlib = Autoloader_.at :memoize,
      :build_require_sidesystem_proc, :build_require_stdlib_proc

    Bundle_Directory = -> mod do
      MetaHell__[]::Bundle::Directory[ mod ]
    end

    Bundle_Multiset = -> mod do
      MetaHell__[]::Bundle::Multiset[ mod ]
    end

    Ellipsify_proc = -> do
      Headless__[]::CLI::FUN::Ellipsify_
    end

    Empty_string_scanner = -> do
      StringScanner__[].new ''
    end

    EN_inflect = -> p do
      Headless__[]::NLP::EN::Minitesimal::FUN.inflect[ p ]
    end

    Enhancement_shell = -> a do
      MetaHell__[]::Enhance::Shell.new a
    end

    Formal_Box_Open = -> do
      MetaHell__[]::Formal::Box::Open
    end

    Funcy_globful = -> x do
      MetaHell__[].funcy_globful x
    end

    Function = -> host, * m_i_a do
      MetaHell__[]::Function._make_methods host, :public, :method, m_i_a
    end

    Functional_methods = -> * a, & p do
      MetaHell__[]::Function::Class.new( * a, & p )
    end

    Headless__ = sidesys[ :Headless ]

    Iambic_parameters = -> * i_a do
      Headless__[]::API::Iambic_parameters[ * i_a ]
    end

    Memoize = -> x do
      Callback_.memoize[ x ]
    end

    MetaHell__ = sidesys[ :MetaHell ]

    Oxford_or = -> a do
      Callback_::Oxford_or[ a ]
    end

    Pool = -> x do
      MetaHell__[]::Pool.enhance x
    end

    Set = -> * a do
      Set__[].new( * a )
    end

    Set__ = stdlib[ :Set ]

    Some_stderr_IO = -> do
      Headless__[]::System::IO.some_stderr_IO
    end

    Strange = -> x do
      MetaHell__[].strange x
    end

    String_IO = -> do
      StringIO__[].new
    end

    StringIO__ = stdlib[ :StringIO ]

    String_scanner = -> str do
      StringScanner__[].new str
    end

    StringScanner__ = memo[ -> do require 'strscan' ; ::StringScanner end ]

    Tmpdir_pathname = -> do
      Headless__[]::System.defaults.tmpdir_pathname
    end
  end
end
