require 'skylab/common'

module Skylab::Brazen

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader
  Lazy_ = Common_::Lazy
  Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

  class << self

    def actionesque_defaults
      Home_::Nodesque::Methods::Actionesque_Defaults
    end

    define_method :application_kernel_, ( Common_.memoize do
      Home_::Kernel.new Home_
    end )

    def branchesque_defaults
      Home_::Nodesque::Methods::Branchesque_Defaults
    end

    def describe_into_under y, expag

      y << "the prototype [br] app (sidelined for now as a real app)"
    end

    def event_class const
      Home_::Actionesque::Factory::Events.const_get const, false
    end

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules Lib___, self
    end

    def members
      singleton_class.instance_methods( false ) - [ :members ]
    end

    def name_library
      Home_::Nodesque::Name
    end

    def name_function
      @nf ||= Common_::Name.via_module self
    end

    def node_identifier
      Home_::Nodesque::Identifier
    end

    def test_support  # #[#ts-035]
      if ! Home_.const_defined? :TestSupport, false
        require_relative '../../test/test-support'
      end
      Home_::TestSupport
    end
  end  # >>

  # == functions that produce procs to be used as method definitions

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x
      instance_variable_set ivar, x
    else
      x
    end
  end

  # == public "magnetics" (functions)

  Ordered_stream_via_participating_stream = -> do  # 1x here, 1x [tm]

    prototype = Lazy_.call do
      Common_::Stream::Magnetics::
          OrderedStream_via_DependencyTree_and_Stream.prototype_by(
      ) do |o|
        o.identifying_key_by = :name_value_for_order.to_proc
        o.reference_key_by = :after_name_value_for_order.to_proc
      end
    end

    -> st do
      prototype[].execute_against st
    end
  end.call

  # == public models or similar (when small stowaways)

  module Models

    # (new in this edition: we only expose a subset of our model for
    # "re-use". see [#ze-066] about model re-use.)

    module Workspace

      Autoloader_[ self ]

      lazily :Magnetics do
        Home_::Models_::Workspace::Magnetics
      end
    end
  end

  module CollectionAdapters

    class << self
      def name_function
        Models_::Collection.name_function  # hack city
      end
    end  # >>

    Autoloader_[ self, :boxxy ]
  end

  module Modelesque

    def self.entity * a, & edit_p
      Entity_lib_[]::Apply_entity_BR[ self::Entity, a, & edit_p ]
    end

    Autoloader_[ self ]
  end

  lazily :Actionesque_ProduceBoundCall do

    _wee = Home_.lib_.plugin::ModelCentricOperatorBranch
    _wee::LEGACY_Brazen_Actionesque_ProduceBoundCall
  end

  # == small functions used locally

  Zerk_lib_ = Lazy_.call do
    Home_.lib_.zerk
  end

  Entity_lib_ = -> do
    Require_fields_lib_[]
    Field_::Entity
  end

  No_deps_zerk_ = Lazy_.call do
    require 'no-dependencies-zerk'
    ::NoDependenciesZerk
  end

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Attributes_ = -> h do
    Home_.lib_.fields::Attributes[ h ]
  end

  Require_fields_lib_ = Lazy_.call do  # ..
    Field_ = Home_.lib_.fields
    NIL_
  end

  Byte_upstream_reference_ = -> do
    Home_.lib_.basic::ByteStream::UpstreamReference
  end

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  Scanner_ = -> a do
    Common_::Scanner.via_array a
  end

  # == singletons, small subclasses

  module THE_EMPTY_EXPRESSION_AGENT_ ; class << self  # c.p from [ts]. 1x here
    alias_method :calculate, :instance_exec
  end ; end

  ArgumentError = ::Class.new ::ArgumentError

  # ==

  module Lib___

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    define_singleton_method :_memoize, Common_::Lazy

    Module_lib = -> do
      Basic[]::Module
    end

    Net_HTTP = _memoize do
      require 'net/http'
      ::Net::HTTP
    end

    Stdlib_option_parser = _memoize do
      require 'optparse'
      ::OptionParser
    end

    Strange = -> x do
      Basic[]::String.via_mixed x
    end

    String_scanner = _memoize do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib[].services
    end

    The_ACS_lib = sidesys[ :Arc ]
    Basic = sidesys[ :Basic ]
    Fields = sidesys[ :Fields ]
    Human = sidesys[ :Human ]
    JSON = stdlib[ :JSON ]
    Open_3 = stdlib[ :Open3 ]
    Parse_lib = sidesys[ :Parse ]
    Pathname = stdlib[ :Pathname ]
    Plugin = sidesys[ :Plugin ]
    String_IO = stdlib[ :StringIO ]
    System_lib = sidesys[ :System ]
    Zerk = sidesys[ :Zerk ]
  end

  # ==

  ACHIEVED_ = true
  ACTIONS_CONST = :Actions
  Box_ = Common_::Box
  CONST_SEP_ = Common_::CONST_SEPARATOR
  DASH_ = '-'.freeze
  DOT_DOT_ = '..'
  EMPTY_A_ = [].freeze
  EMPTY_H_ = {}.freeze
  EMPTY_P_ = -> { NIL_ }
  EMPTY_S_ = ''.freeze
  Home_ = self
  IDENTITY_ = -> x { x }
  KEEP_PARSING_ = true
  Autoloader_[ Models_ = ::Module.new, :boxxy ]
  MONADIC_EMPTINESS_ = -> _ { NIL_ }
  NAME_SYMBOL = :name
  NEWLINE_ = "\n".freeze
  NIL_ = nil
  NOTHING_ = nil
  SPACE_ = ' '.freeze
  stowaway :TestSupport, 'test/test-support'
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze
  UNRELIABLE_ = false
end
