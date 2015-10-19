module Skylab::CodeMolester

  module Library_

    quietly, stdlib = Autoloader_.at :require_quietly,  :require_stdlib

    o = { }
    o[ :FileUtils ] =
    o[ :Psych ] =
    o[ :Set ] =
    o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }
    o[ :Treetop ] = quietly
    o[ :YAML ] = stdlib

    define_singleton_method :const_missing do |i|
      o.key? i or super i
      const_set i, o.fetch( i )[ i ]
    end

    class << self
      def touch i
        const_defined?( i, false ) or const_get( i, false ) ; nil
      end
    end
  end

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    define_singleton_method :_memoize, Callback_::Memoize

    Basic = sidesys[ :Basic ]

    Brazen = sidesys[ :Brazen ]

    Existent_cache_dir = _memoize do
      path = ::File.join System[].defaults.cache_path, '[cm]'
      if ! ::File.exist? path
        ::Dir.mkdir path
      end
      path
    end

    Human = sidesys[ :Human ]

    Parse = sidesys[ :Parse ]

    Plugin = sidesys[ :Plugin ]

    System = -> do
      System_lib[].services
    end

    System_lib = sidesys[ :System ]

  end

  LIB_ = Callback_.produce_library_shell_via_library_and_app_modules Lib_, Home_

end
