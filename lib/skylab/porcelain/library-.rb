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

    Bsc__ = sidesys[ :Basic ]

    CLI_lib = -> do
      HL__[]::CLI
    end

    HL__ = sidesys[ :Headless ]

    NLP = -> do
      HL__[]::NLP
    end

    String_lib = -> do
      Bsc__[]::String
    end

    INSTANCE = Callback_.produce_library_shell_via_library_and_app_modules(
      self, Porcelain_ )
  end

  LIB_ = Lib_::INSTANCE

end
