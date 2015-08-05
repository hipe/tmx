module Skylab::Callback

  module Lib_  # :+[#ss-001]

    sidesys = Autoloader.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]

    Digraph_lib = -> do
      Basic[]::Digraph
    end

    Boxlike_as_proxy_to_hash = -> h do
      Home_::Box.allocate.instance_exec do
        @a = h.keys ; @h = h
        self
      end
    end

    Bundle_multiset = -> x do
      Plugin[]::Bundle::Multiset[ x ]
    end

    Brazen = sidesys[ :Brazen ]

    Class_lib = -> do
      Basic[]::Class
    end

    Enhancement_shell = -> a do
      Plugin[]::Bundle::Enhance::Shell.new a
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

    Hu__ = sidesys[ :Human ]

    IO_lib = -> do
      System_lib__[]::IO
    end

    Levenshtein = -> do
      Hu__[]::Levenshtein
    end

    List_lib = -> do
      Basic[]::List
    end

    Module_lib = -> do
      Basic[]::Module
    end

    Parse = sidesys[ :Parse ]

    Plugin = sidesys[ :Plugin ]

    Some_stderr = -> do
      System_lib__[]::IO.some_stderr_IO
    end

    Stdlib_option_parser = -> do
      require 'optparse' ; ::OptionParser
    end

    Strange = -> do
      p = -> x do
        _LENGTH_OF_A_LONG_LINE = 120
        p = Basic[]::String.via_mixed.curry[ _LENGTH_OF_A_LONG_LINE ]
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
      System_lib__[].services
    end

    System_lib__ = sidesys[ :System ]

    Test_support = sidesys[ :TestSupport ]
  end
end
