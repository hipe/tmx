module Skylab::Porcelain

  module Library_  # :+[#su-001]

    o = { }
    o[ :Basic ] = -> _ { require 'skylab/basic/core' ; ::Skylab::Basic }
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :StringIO ] = Autoloader_.method :require_stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }

    define_singleton_method :const_missing do |c|
      const_set c, o.fetch( c )[ c ]
    end
  end

  module Lib_
    sidesys = Autoloader_.build_require_sidesystem_proc
    Basic_Fields = -> * x_a do
      if x_a.length.zero?
        MetaHell__[]::Basic_Fields
      else
        MetaHell__[]::Basic_Fields.via_iambic x_a
      end
    end
    CLI = -> do
      Headless__[]::CLI
    end
    Function_chain = -> x, y do
      MetaHell__[]::FUN::Function_chain_[ x, y ]
    end
    Funcy_globless = -> client do
      MetaHell__[]::Funcy_globless[ client ]
    end
    Funcy_globful = -> client do
      MetaHell__[]::Funcy[ client ]
    end
    MetaHell__ = MetaHell_ = sidesys[ :MetaHell ]
    NLP = -> do
      Headless__[]::NLP
    end
    Headless__ = Headless_ = sidesys[ :Headless ]
  end
end
