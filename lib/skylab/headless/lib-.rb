module Skylab::Headless

  module Library_

    stdlib = Autoloader_.method :require_stdlib

    o = { }
    o[ :FileUtils ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Set ] = stdlib
    o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }

    # ~ just do it live and implement small things here potentially redundantly

    Memoize = -> p do  # (legacy interface)
      Callback_::Memoize[ & p ]
    end

    def self.const_missing i
      const_set i, @o.fetch( i )[ i ]
    end ; @o = o.freeze
  end

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]

    Code_molester = sidesys[ :CodeMolester ]

    Meso_box_lib = -> do
      Basic[]::Box
    end

    Bundle = -> do
      MH__[]::Bundle
    end

    DSL_DSL = -> mod, p do
      Parse_lib[]::DSL_DSL.enhance mod, &p
    end

    Enumerator_lib = -> do
      Basic[]::Enumerator
    end

    Face___ = sidesys[ :Face ]

    Funcy_globful = -> cls do
      MH__[].funcy_globful cls
    end

    List_lib = -> do
      Basic[]::List
    end

    MH__ = sidesys[ :MetaHell ]

    Method_lib = -> do
      Basic[]::Method
    end

    Module_lib = -> do
      Basic[]::Module
    end

    Other_CLI_table = -> * x_a do
      Face___[]::CLI::Table.call_via_iambic x_a
    end

    Parse_lib = sidesys[ :Parse ]

    Reasonably_short = -> do
      Strange_lib[]::A_REASONABLY_SHORT_LENGTH_FOR_A_STRING
    end

    Strange = -> x do
      Basic[]::String.via_mixed x
    end

    String_lib = -> do
      Basic[]::String
    end

    System = -> do
      System_lib___[].services
    end

    System_lib___ = sidesys[ :System ]
  end
end
