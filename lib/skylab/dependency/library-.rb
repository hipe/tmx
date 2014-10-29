module Skylab::Dependency

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    CLI_lib = -> do
      HL__[]::CLI
    end

    CodeMolester__ = sidesys[ :CodeMolester ]

    Face__ = sidesys[ :Face ]

    Home_dir_pn = -> do
      System__[].environment.any_home_directory_pathname
    end

    HL__ = sidesys[ :Headless ]

    MH__ = sidesys[ :MetaHell ]

    Methodize = -> i do
      Callback_::Name.lib.methodize i
    end

    Open_2 = -> mod do
      mod.send :include, Face__[]::Open2
    end

    Path_tools = -> do
      HL__[].system.filesystem.path_tools
    end

    Proxy = -> do
      MH__[]::Proxy
    end

    Sexp = -> do
      CodeMolester__[]::Sexp
    end

    Slake = sidesys[ :Slake ]

    System = -> do
      HL__[].system
    end

    Writemode = -> do
      HL__[]::WRITE_MODE_
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
