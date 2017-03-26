require 'skylab/common'

module Skylab::SubTree

  def self.describe_into_under y, _
    y << "an umbrella node for varous operations on a filesystem tree"
  end

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader

  module API

    class << self

      def call * x_a, & oes_p
        bc = application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args
      end

      define_method :application_kernel_, ( Common_.memoize do
        Home_.lib_.brazen::Kernel.new Home_
      end )

      def action_class_
        Home_.lib_.brazen::Action
      end
    end  # >>
  end

  class << self

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x then instance_variable_set ivar, x ; else x end
  end

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  module Models_

    Autoloader_[ self, :boxxy ]

    stowaway :Directories, 'directories/actions/dirstat'
  end

  # --

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    _System_lib = nil

    System = -> do
      System_lib[].services
    end

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Human = sidesys[ :Human ]
    System_lib = sidesys[ :System ]
    Zerk = sidesys[ :Zerk ]
  end

  module Library_

    stdlib = Autoloader_.method :require_stdlib

    o = {}
    o[ :FileUtils ] = stdlib
    o[ :Open3 ] = stdlib
    o[ :Shellwords ] = stdlib
    o[ :StringIO ] = stdlib
    o[ :Time ] = stdlib

    define_singleton_method :const_missing do |sym|
      const_set sym, o.fetch( sym )[ sym ]
    end
  end

  # --

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  ACHIEVED_ = true
  DASH_ = '-'.freeze
  DEFAULT_GLYPHSET_IDENTIFIER_ = :narrow
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  KEEP_PARSING_ = true
  IDENTITY_ = -> x { x }
  stowaway :Library_, 'lib-'
  NEWLINE_ = "\n"
  NIL_ = nil
  SEP_ = ::File::SEPARATOR
  Home_ = self
  SPACE_ = ' '.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze
end
# :+#tombstone: dedicated API node
