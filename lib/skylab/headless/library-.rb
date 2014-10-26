module Skylab::Headless

  module Library_  # :+[#su-001]

    stdlib, sidesys = Autoloader_.at :require_stdlib, :require_sidesystem

    o = { }
    o[ :CodeMolester ] = sidesys
    o[ :FileUtils ] = stdlib
    o[ :InformationTactics ] = o[ :MetaHell ] = sidesys
    o[ :Open3 ] = stdlib
    o[ :Open4 ] = -> { Autoloader_.require_quiety( 'open4' ) ; ::Open4 }
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Callback ] = sidesys
    o[ :Set ] = stdlib
    o[ :Shellwords ] = o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }
    o[ :Tmpdir ] = -> _ { require 'tmpdir' ; ::Dir }
    o[ :TreetopTools ] = sidesys

    # ~ just do it live and implement small things here potentially redundantly

    Memoize = Callback_.memoize

    def self.const_missing i
      const_set i, @o.fetch( i )[ i ]
    end ; @o = o.freeze
  end

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Bsc__ = sidesys[ :Basic ]

    Meso_box_lib = -> do
      Bsc__[]::Box
    end

    Bzn__ = sidesys[ :Brazen ]

    Bundle = -> do
      MH__[]::Bundle
    end

    DSL_DSL = -> mod, p do
      MH__[]::DSL_DSL.enhance mod, &p
    end

    Entity = -> * a, & p do
      if a.length.zero? && ! p
        Bzn__[]::Entity
      else
        p and a.push p
        Bzn__[]::Entity.via_arglist a
      end
    end

    Enumerator_lib = -> do
      Bsc__[]::Enumerator
    end

    Event_lib = -> do
      Bzn__[].event
    end

    Funcy_globful = -> cls do
      MH__[].funcy_globful cls
    end

    IT__ = sidesys[ :InformationTactics ]

    Ivars_with_procs_as_methods = -> * a do
      MH__[]::Ivars_with_Procs_as_Methods.via_arglist a
    end

    Levenshtein = -> do
      IT__[]::Levenshtein
    end

    List_lib = -> do
      Bsc__[]::List
    end

    MH__ = sidesys[ :MetaHell ]

    Method_lib = -> do
      Bsc__[]::Method
    end

    Module_lib = -> do
      Bsc__[]::Module
    end

    Old_box_lib = -> do
      MH__[]::Formal::Box
    end

    Parse_series = -> * a do
      MH__[]::Parse.series.via_arglist a
    end

    Properties_stack_frame = -> *a do
      Bzn__[].properties_stack.common_frame.via_arglist a
    end

    Pool = -> do
      MH__[]::Pool
    end

    Proxy_lib = -> do
      Callback_::Proxy
    end

    Reasonably_short = -> do
      MH__[].strange::A_REASONABLY_SHORT_LENGTH_FOR_A_STRING
    end

    Strange = -> x do
      MH__[].strange x
    end

    String_lib = -> do
      Bsc__[]::String
    end
  end
end
