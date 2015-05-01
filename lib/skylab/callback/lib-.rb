module Skylab::Callback

  module Lib_  # :+[#ss-001]

    sidesys = Autoloader.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]

    Digraph_lib = -> do
      Basic[]::Digraph
    end

    Boxlike_as_proxy_to_hash = -> h do
      Callback_::Box.allocate.instance_exec do
        @a = h.keys ; @h = h
        self
      end
    end

    Bundle_item_grammar = -> do
      MH__[]::Bundle::Item_Grammar
    end

    Bundle_multiset = -> x do
      MH__[]::Bundle::Multiset[ x ]
    end

    Brazen = sidesys[ :Brazen ]

    Class_lib = -> do
      MH__[]::Class
    end

    CLI_lib = -> do
      HL__[]::CLI
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

    Enum_lib = -> do
      Basic[]::Enumerator
    end

    Hash_lib = -> do
      Basic[]::Hash
    end

    HL__ = sidesys[ :Headless ]

    IO_lib = -> do
      HL__[]::IO
    end

    Ivars_with_procs_as_methods = -> * a do
      MH__[]::Ivars_with_Procs_as_Methods.call_via_arglist a
    end

    Let = -> do
      MH__[]::Let
    end

    Levenshtein = -> do
      IT__[]::Levenshtein
    end

    List_lib = -> do
      Basic[]::List
    end

    IT__ = sidesys[ :InformationTactics ]

    MH__ = sidesys[ :MetaHell ]

    Module_lib = -> do
      Basic[]::Module
    end

    Num2ord = -> x do
      HL__[]::NLP::EN::Number::Num2ord[ x ]
    end

    Some_stderr = -> do
      HL__[]::System::IO.some_stderr_IO
    end

    Stdlib_option_parser = -> do
      require 'optparse' ; ::OptionParser
    end

    Strange = -> do
      p = -> x do
        _LENGTH_OF_A_LONG_LINE = 120
        p = MH__[].strange.curry[ _LENGTH_OF_A_LONG_LINE ]
        p[ x ]
      end
      -> x { p[ x ] }
    end.call

    StringScanner = -> do
      require 'strscan' ; ::StringScanner
    end

    String_lib = -> do
      Basic[]::String
    end

    Struct_lib = -> do
      Basic[]::Struct
    end

    System = -> do
      HL__[].system
    end
  end
end
