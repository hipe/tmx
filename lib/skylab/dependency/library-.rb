module Skylab::Dependency

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    CLI = -> do
      Headless__[]::CLI
    end

    CodeMolester__ = sidesys[ :CodeMolester ]

    Face__ = sidesys[ :Face ]

    Home_dir_pn = -> do
      Headless__[]::FUN.home_directory_pathname
    end

    Headless__ = sidesys[ :Headless ]

    MetaHell__ = sidesys[ :MetaHell ]

    Methodize = -> i do
      ::Skylab::Autoloader::FUN::Methodize[ i ]
    end

    Open_2 = -> mod do
      mod.send :include, Face__[]::Open2
    end

    Proxy = -> do
      MetaHell__[]::Proxy
    end

    Sexp = -> do
      CodeMolester__[]::Sexp
    end

    Slake = sidesys[ :Slake ]

    Writemode = -> do
      Headless__[]::WRITEMODE_
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
