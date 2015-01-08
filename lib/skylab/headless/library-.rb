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

    Basic = sidesys[ :Basic ]

    Meso_box_lib = -> do
      Basic[]::Box
    end

    Bzn_ = sidesys[ :Brazen ]

    Bundle = -> do
      MH__[]::Bundle
    end

    DSL_DSL = -> mod, p do
      MH__[]::DSL_DSL.enhance mod, &p
    end

    Entity = -> * a, & p do
      if a.length.zero? && ! p
        Bzn_[]::Entity
      else
        Bzn_[]::Entity.via_arglist a, & p
      end
    end

    Enumerator_lib = -> do
      Basic[]::Enumerator
    end

    Event_lib = -> do
      Bzn_[].event
    end

    Funcy_globful = -> cls do
      MH__[].funcy_globful cls
    end

    Ivars_with_procs_as_methods = -> * a do
      MH__[]::Ivars_with_Procs_as_Methods.via_arglist a
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

    Parse_series = -> * a do
      MH__[]::Parse.series.via_arglist a
    end

    Properties_stack_frame = -> *a do
      Bzn_[].properties_stack.common_frame.via_arglist a
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

    Shellwords = Callback_.memoize do
      require 'shellwords'
      ::Shellwords
    end

    Strange = -> x do
      MH__[].strange x
    end

    String_lib = -> do
      Basic[]::String
    end

    Tree_lib = -> do
      Basic[]::Tree
    end
  end
end
