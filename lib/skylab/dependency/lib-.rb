module Skylab::Dependency

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Ba___ = sidesys[ :Basic ]

    Brazen = sidesys[ :Brazen ]

    CodeMolester__ = sidesys[ :CodeMolester ]

    Home_dir_pn = -> do
      System_lib___[].services.environment.any_home_directory_pathname
    end

    Methodize = -> i do
      Callback_::Name.lib.methodize i
    end

    Path_tools = -> do
      System[].filesystem.path_tools
    end

    Sexp = -> do
      Ba___[]::Sexp
    end

    Slake = sidesys[ :Slake ]

    _System = sidesys[ :System ]

    System = -> do
      _System[].services
    end
  end

  module Library_  # :+[#su-001]

    def self.const_missing const_i
      m_i = load_methodize const_i
      if respond_to? m_i
        const_set const_i, send( m_i )
      else
        fail "no such service defined - #{ const_i }"
        # NameError: uninitialized constant Foo::Bar
      end
    end

    def self.o const_i, p
      define_singleton_method load_methodize( const_i ), & p
    end

    def self.load_methodize i
      :"load_#{ Lib_::Methodize[ i ] }"
    end

    o :FileUtils, -> { require 'fileutils' ; ::FileUtils }

    o :StringIO, -> { require 'stringio' ; ::StringIO }

    o :StringScanner, -> { require 'strscan' ; ::StringScanner }

    o :Tree, -> { self::Basic__::Tree }  # for the future if ever

  end
end
