require 'skylab/common'

module Skylab::TMX

  def self.describe_into_under y, _
    y << "uh.."
  end

  Common_ = ::Skylab::Common
  Lazy_ = Common_::Lazy

  class << self

    def to_common_unparsed_node_stream__

      dir = ::File.expand_path '../../..', dir_path  # sidesys_path_

      stat = ::File.lstat dir

      if stat.symlink?
        dir_ = ::File.readlink dir
      else
        dir_ = dir
      end

      _yikes = ::File.dirname dir_

      Home_::Magnetics::
        UnparsedNodeStream_via::DevelopmentDirectory.call(
          _yikes, ::Dir, ::File )
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

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  Autoloader_ = Common_::Autoloader

  # ==

  DEFINITION_FOR_THE_METHOD_CALLED_PARSE_INTO_ = -> ivar, * x_a do

    req = @argument_scanner.parse_parse_request x_a

    x = @argument_scanner.parse_primary_value_via_parse_request req

    if x
      if ! req.must_be_trueish
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

  Box_via_autoloaderized_module_ = -> mod do

    # simplified and more rigid alternative to [co] "boxxy". memoize result.

    bx = Common_::Box.new
    st = mod.entry_tree.to_state_machine_stream
    begin
      sm = st.gets
      sm || break
      name = Common_::Name.via_slug sm.entry_group_head
      bx.add name.as_lowercase_with_underscores_symbol, name
      redo
    end while above
    bx
  end

  Zerk_ = Lazy_.call do
    Autoloader_.require_sidesystem :Zerk
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

    _System_lib = sidesys[ :System ]
    System = -> do
      _System_lib[].services
    end

    Human = sidesys[ :Human ]

    JSON = stdlib[ :JSON ]
  end

  # ==

  ACHIEVED_ = true
  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]
  DASH_ = '-'
  EMPTY_S_ = ''
  MONADIC_EMPTINESS_ = -> _ { NOTHING }
  NIL_ = nil
  NOTHING_ = nil
  Home_ = self
  UNABLE_ = false
end
