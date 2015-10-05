module Skylab::Git

  module Library_

    stdlib, = Autoloader_.at :require_stdlib

    o = { }
    o[ :FileUtils ] = stdlib
    o[ :Open3 ] = stdlib
    o[ :OptionParser ] = -> _ { require 'optparse' ; ::OptionParser }
    o[ :Set ] = o[ :Shellwords ] = o[ :StringIO ] = stdlib

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    Basic = sidesys[ :Basic ]

    Brazen = sidesys[ :Brazen ]

    Fields = sidesys[ :Fields ]

    FUC = -> do
      System[].filesystem.file_utils_controller
    end

    Git_viz = sidesys[ :GitViz ]

    Open_3 = stdlib[ :Open3 ]

    Plugin = sidesys[ :Plugin ]

    Shellwords = -> do
      require 'shellwords'
      ::Shellwords
    end

    _System_lib = sidesys[ :System ]

    System = -> do
      _System_lib[].services
    end
  end
end
