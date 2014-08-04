module Skylab::Porcelain

  module Library_  # :+[#su-001]

    o = { }
    o[ :Basic ] = -> _ { require 'skylab/basic/core' ; ::Skylab::Basic }
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }

    define_singleton_method :const_missing do |c|
      const_set c, o.fetch( c )[ c ]
    end
  end

  module Lib_
    sidesys = Autoloader_.build_require_sidesystem_proc
    CLI = -> do
      Headless__[]::CLI
    end
    NLP = -> do
      Headless__[]::NLP
    end
    Headless__ = Headless_ = sidesys[ :Headless ]
  end
end
