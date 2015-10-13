require 'skylab/callback'

module Skylab::TMX

  def self.describe_into_under y, _
    y << "uh.."
  end

  Callback_ = ::Skylab::Callback

  class << self

    def lookup_sidesystem entry_s
      installation_.lookup_reflective_sidesystem__ entry_s
    end

    def build_sigilized_list

      ss_a = to_reflective_sidesystem_stream.to_a

      Home_.lib_.slicer.distribute_sigils ss_a

      ss_a
    end

    def to_reflective_sidesystem_stream
      installation_.to_reflective_sidesystem_stream__
    end

    def to_sidesystem_load_ticket_stream
      installation_.to_sidesystem_load_ticket_stream
    end

    define_method :application_kernel_, ( Callback_.memoize do
      Home_.lib_.brazen::Kernel.new Home_
    end )

    def installation_
      @___installation ||= __build_installation
    end

    def __build_installation

      o = Home_::Models_::Installation.new

      o.single_gems_dir = ::File.join ::Gem.paths.home, 'gems'
      o.participating_gem_prefix = 'skylab-'
      o.participating_gem_const_path_head = [ :Skylab ]
      o.participating_exe_prefix = 'tmx-'

      o.done
    end

    def lib_
      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys, _stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Slicer = sidesys[ :Slicer ]

    _System_lib = sidesys[ :System ]
    System = -> do
      _System_lib[].services
    end
  end

  module Models_
    Autoloader_[ self ]
    Sidesystem = Autoloader_[ ::Module.new ]
  end

  ACHIEVED_ = true
  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ]]
  DASH_ = '-'
  NIL_ = nil
  Home_ = self
  UNDERSCORE_ = '_'
end
