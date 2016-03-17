module Skylab::TaskExamples

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Ba___ = sidesys[ :Basic ]

    Brazen = sidesys[ :Brazen ]

    CodeMolester__ = sidesys[ :CodeMolester ]

    Home_dir_pn = -> do
      System_lib___[].services.environment.any_home_directory_pathname
    end

    Methodize = -> sym do
      self._HELLO
      Callback_::Name::Methodize[ sym ]
    end

    Path_tools = -> do
      System[].filesystem.path_tools
    end

    Sexp = -> do
      Ba___[]::Sexp
    end

    Task = sidesys[ :Task ]

    System = -> do
      System_lib[].services
    end

    System_lib = sidesys[ :System ]
  end

  module Library_  # :+[#su-001]

    # #todo etc

    class << self

      cache = {}
      define_method :o do | sym, & p |
        cache[ sym ] = p
      end

      define_method :const_missing do | sym |
        x = cache.fetch( sym ).call
        const_set sym, x
        x
      end
    end  # >>

    o :FileUtils do
      require 'fileutils'
      ::FileUtils
    end

    o :Shellwords do
      require 'shellwords'
      ::Shellwords
    end

    o :StringIO do
      require 'stringio'
      ::StringIO
    end

    o :StringScanner do
      require 'strscan'
      ::StringScanner
    end
  end
end
