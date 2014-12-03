module Skylab::Callback

  module Lib_  # :+[#ss-001]

    sidesys = Autoloader.build_require_sidesystem_proc

    Bsc__ = sidesys[ :Basic ]

    Digraph_lib = -> do
      Bsc__[]::Digraph
    end

    Boxlike_as_proxy_to_hash = -> h do
      Old_box_lib[].open_box.hash_controller h
    end

    Bundle_Item_Grammar = -> do
      MH__[]::Bundle::Item_Grammar
    end

    Bundle_Multiset = -> x do
      MH__[]::Bundle::Multiset[ x ]
    end

    Bzn__ = sidesys[ :Brazen ]

    Class = -> do
      MH__[]::Class
    end

    CLI_lib = -> do
      HL__[]::CLI
    end

    Enhancement_shell = -> a do
      MH__[]::Enhance::Shell.new a
    end

    Entity = -> * a do
      if a.length.zero?
        Bzn__[]::Entity
      else
        Bzn__[]::Entity.via_arglist a
      end
    end

    Enum_lib = -> do
      Bsc__[]::Enumerator
    end

    Event_lib = -> do
      Bzn__[].event
    end

    Hash_lib = -> do
      Bsc__[]::Hash
    end

    HL__ = sidesys[ :Headless ]

    IO_lib = -> do
      HL__[]::IO
    end

    Ivars_with_procs_as_methods = -> * a do
      MH__[]::Ivars_with_Procs_as_Methods.via_arglist a
    end

    Let = -> do
      MH__[]::Let
    end

    Levenshtein = -> do
      IT__[]::Levenshtein
    end

    List_lib = -> do
      Bsc__[]::List
    end

    IT__ = sidesys[ :InformationTactics ]

    MH__ = sidesys[ :MetaHell ]

    Memoize = Memoize_  # as you like it

    Module_lib = -> do
      Bsc__[]::Module
    end

    Num2ord = -> x do
      HL__[]::NLP::EN::Number::Num2ord[ x ]
    end

    Old_box_lib = -> do
      MH__[]::Formal::Box
    end

    Old_name_lib = -> do
      HL__[]::Name
    end

    Quickie = -> x do
      x.extend TestSupport__[]::Quickie
    end

    Scn = -> & p do
      HL__[]::Scn.new( & p )
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
      Bsc__[]::String
    end

    Struct_lib = -> do
      Bsc__[]::Struct
    end

    TestSupport_ = TestSupport__ = sidesys[ :TestSupport ]

    Writemode = -> do
      HL__[]::WRITE_MODE_
    end
  end
end
