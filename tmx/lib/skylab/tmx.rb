require 'skylab/common'

module Skylab::TMX

  def self.describe_into_under y, _
    y << "uh.."
  end

  Common_ = ::Skylab::Common
  Lazy_ = Common_::Lazy

  class << self

    def development_directory_json_file_stream__ & emit

      # (compare `installation_.to_sidesystem_load_ticket_stream`)

      _dir = __lookup_development_directory
      glob = ::File.join _dir, '*', METADATA_FILENAME
      files = ::Dir.glob glob
      if files.length.zero?
        emit.call :error, :expression, :zero_nodes do |y|
          y << "found no files for #{ glob }"
        end
        UNABLE_
      else
        Stream_[ files ]
      end
    end

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

    define_method :application_kernel_, ( Lazy_.call do
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

    def __lookup_development_directory

      dir = sidesystem_path_

      stat = ::File.lstat dir

      if stat.symlink?  # explained at [#tm-013.1]
        dir = ::File.readlink dir
      end

      ::File.dirname dir
    end

    def test_support  # #[#ts-035]
      @___test_support ||= begin
        require_relative '../../test/test-support' ; Home_::TestSupport
      end
    end

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end

    def sidesystem_path_
      @___ssp ||= ::File.expand_path '../../..', dir_path
    end
  end  # >>

  Autoloader_ = Common_::Autoloader

  # ==

  DEFINITION_FOR_THE_METHOD_CALLED_PARSE_INTO_ = -> ivar, * x_a do

    req = @argument_scanner.parse_parse_request x_a

    x = @argument_scanner.parse_primary_value_via_parse_request req

    if x
      if req.successful_result_will_be_wrapped
        x = x.value_x
      end
      instance_variable_set ivar, x
      ACHIEVED_
    end
  end

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x
      instance_variable_set ivar, x ; ACHIEVED_
    else
      x
    end
  end

  # ==

  Zerk_lib_ = Lazy_.call do
    mod = Autoloader_.require_sidesystem :Zerk
    Zerk_ = mod
    mod
  end

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  # ==

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]

    Human = sidesys[ :Human ]

    _System_lib = sidesys[ :System ]
    System = -> do
      _System_lib[].services
    end

    JSON = stdlib[ :JSON ]

    Test_support = sidesys[ :TestSupport ]
  end

  # ==

  ACHIEVED_ = true
  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]
  DASH_ = '-'
  DOT_ = '.'
  EMPTY_P_ = -> { NOTHING_ }
  EMPTY_S_ = ''
  Home_ = self
  METADATA_FILENAME = '.for-tmx-map.json'
  MONADIC_EMPTINESS_ = -> _ { NOTHING_ }
  NEWLINE_ = "\n"
  NIL_ = nil
  NOTHING_ = nil
  SPACE_ = ' '
  UNABLE_ = false
  UNDERSCORE_ = '_'
end
