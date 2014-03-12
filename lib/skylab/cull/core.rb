require_relative '../callback/core'

module Skylab::Cull

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader
  couple = Autoloader_.method :require_sidesystem

  CodeMolester = couple[ :CodeMolester ]
  Cull = self
  Face = couple[ :Face ]

  module CLI
    def self.new *a, &p
      self::Client.new( *a, &p )
    end
    Autoloader_[ self ]
  end

  module API
    module Actions
      Autoloader_[ self, :boxxy ]
    end
    module Events_
      # gets filled with generated event classes
    end
    Autoloader_[ self, :boxxy ]  # peek to find client
  end


  Models = Autoloader_[ ::Module.new, :boxxy ]

  module Lib_  # :+[#su-001]

    sidesys, stdlib = Autoloader_.at :build_require_sidesystem_proc,
      :build_require_stdlib_proc

    Headless__ = sidesys[ :Headless ]

    FileUtils = stdlib[ :FileUtils ]

    Name_slugulate = -> i do
      Callback_::Name.from_variegated_symbol( i ).as_slug
    end

    System_default_tmpdir_pathname = -> do
      Headless__[]::System.defaults.tmpdir_pathname
    end

    Pretty_path_safe = -> x do
      Headless__[]::CLI::PathTools::FUN.pretty_path_safe[ x ]
    end
  end

  Autoloader_[ self, ::Pathname.new( ::File.dirname( __FILE__ ) ) ]

end
