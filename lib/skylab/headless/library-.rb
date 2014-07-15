module Skylab::Headless

  module Library_  # :+[#su-001]

    stdlib, sidesys = Autoloader_.at :require_stdlib, :require_sidesystem

    o = { }
    o[ :Basic ] = sidesys
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
    Bundle = -> do
      MetaHell__[]::Bundle
    end
    DSL_DSL = -> mod, p do
      MetaHell__[]::DSL_DSL.enhance mod, &p
    end
    FUN_module = -> do
      MetaHell__[]::FUN::Module
    end
    Formal_box = -> do
      MetaHell__[]::Formal::Box
    end
    Function_class = -> do
      MetaHell__[]::Function::Class
    end
    Funcy_globful = -> cls do
      MetaHell__[].funcy_globful cls
    end
    MetaHell__ = sidesys[ :MetaHell ]
    Module_resolve = -> path_s, mod do
      MetaHell__[]::Module::Resolve[ path_s, mod ]
    end
    Parse_series = -> * x_a do
      MetaHell__[]::FUN.parse_series[ * x_a ]
    end
    Pool = -> do
      MetaHell__[]::Pool
    end
    Private_attr_reader = -> do
      MetaHell__[]::FUN.private_attr_reader
    end
    Proxy_tee = -> do
      MetaHell__[]::Proxy::Tee
    end
  end
end
