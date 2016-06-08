require 'skylab/common'

module Skylab::TMX

  def self.describe_into_under y, _
    y << "uh.."
  end

  Common_ = ::Skylab::Common

  class << self

    def build_sigilized_sidesystem_stream_plus stem

      # what tmx reports as the "sidesystem stream" is based on the gems
      # found to be installed. you may want to have included as a sigilized
      # sidesystem a sidesystem that has not yet been made a gem, for example
      # if you are making it into a gem..

      st = to_sidesystem_load_ticket_stream
      bx = Common_::Box.new
      begin
        lt = st.gets
        bx.add lt.stem, lt
      end while nil

      if stem and ! bx.has_name stem
        stemmish = Stemmish___[ stem ]
        bx.add stemmish.stem, stemmish
      end

      _anything = Home_::Models::Sigil.via_stemish_box bx

      _anything.to_stream
    end

    Stemmish___ = ::Struct.new :stem

    def lookup_sidesystem entry_s
      installation_.lookup_reflective_sidesystem__ entry_s
    end

    def to_reflective_sidesystem_stream
      installation_.to_reflective_sidesystem_stream__
    end

    def to_sidesystem_load_ticket_stream
      installation_.to_sidesystem_load_ticket_stream
    end

    define_method :application_kernel_, ( Common_.memoize do
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
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  Autoloader_ = Common_::Autoloader

  module Lib_

    sidesys, _stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]

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
  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]
  DASH_ = '-'
  EMPTY_S_ = ''
  NIL_ = nil
  Home_ = self
end
