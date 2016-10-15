require 'skylab/common'

module Skylab::Cull

  def self.describe_into_under y, _expag
    y << "reduce a search space by a criteria - i.e helps make decisions"
  end

  Common_ = ::Skylab::Common

  Autoloader_ = Common_::Autoloader

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  lazily :CLI do
    ::Class.new Brazen_::CLI
  end

  module API

    class << self

      def call * x_a, & oes_p
        bc = Home_.application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end
    end  # >>
  end

  module Models_
    Autoloader_[ self, :boxxy ]
  end

  Models_::Ping = -> bound, & oes_p do

    oes_p.call :info, :ping do

      Common_::Event.wrap.signature(
        bound.unbound.name_function,
        ( Common_::Event.inline_neutral_with :ping do | y, o |
          y << "hello from #{ bound.kernel.app_name }."
        end ) )
    end

    :hello_from_cull
  end

  Lazy_ = Common_::Lazy

  class << self

    define_method :application_kernel_, ( Lazy_.call do
      Brazen_::Kernel.new Home_
    end )

    def lib_
      @lib ||= Common_.produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  Common_entity_ = -> * x_a, & x_p do

    Brazen_::Entity::Apply_entity[ Brazen_::Modelesque::Entity, x_a, & x_p ]
  end

  # == METHODS

  HARD_CALL_METHOD_ = -> * values, arg_box, & oes_p do  # 1x

    st = const_get( :ATTRIBUTES, false ).to_defined_attribute_stream

    o = begin_session__( & oes_p )

    values.length.times do |d|
      _atr = st.gets
      o.instance_variable_set _atr.as_ivar, values.fetch( d )
    end

    begin
      atr = st.gets
      atr or break
      _ivar = :"#{ atr.as_ivar }_arg"
      _x = arg_box.fetch atr.name_symbol
      o.instance_variable_set _ivar, _x
      redo
    end while nil

    o.execute
  end

  VALUE_BOX_EXPLODER_CALL_METHOD_ = -> value_box, & oes_p do  # 1x

    # for every defined attribute (only the names matter), read the value
    # from the value box and write it to the session as an ivar. then execute.

    o = begin_session__( & oes_p )

    st = const_get( :ATTRIBUTES, false ).to_defined_attribute_stream

    begin
      atr = st.gets
      atr or break
      o.instance_variable_set atr.as_ivar, value_box[ atr.name_symbol ]
      redo
    end while nil

    o.execute
  end

  FUNCTION_NAME_CONVENTION_ = -> name do
    s = name.as_lowercase_with_underscores_string
    s[ 0 ] = s[ 0 ].upcase
    s.intern
  end

  module Special_boxxy_

    # memoize special index information about its constituency *into* the
    # module for use in unmarshaling

    class << self
      def call mod
         Autoloader_[ mod, :boxxy ]
         mod.extend self ; nil
      end
      alias_method :[], :call
    end  # >>

    def to_special_boxxy_item_name_stream__
      _a = ( @___special_index ||= __build_item_index_array )
      Common_::Stream.via_nonsparse_array _a
    end

    def __build_item_index_array

      _hi = constants  # assume these are boxxy (some or all are inferred)

      _hey = _hi.map do |const|
        Common_::Name.via_const_symbol const
      end

      _hey.freeze
    end

    define_method :boxxy_const_guess_via_name, FUNCTION_NAME_CONVENTION_
  end

  # == FUNCTIONS

  Attributes_ = -> h do
    Home_.lib_.fields::Attributes[ h ]
  end

  Build_not_OK_event_ = -> * i_a, & msg_p do
    i_a.push :ok, false
    Common_::Event.inline_via_iambic_and_any_message_proc_to_be_defaulted i_a, msg_p
  end

  Build_event_ = -> * i_a, & msg_p do
    Common_::Event.inline_via_iambic_and_any_message_proc_to_be_defaulted i_a, msg_p
  end

  # ==

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]

    # = sidesys[ :Brazen ]  # for [sl]

    Fields = sidesys[ :Fields ]

    Filesystem = -> do
      System[].filesystem
    end

    Load_JSON_lib = -> do
      require 'json'
      nil
    end

    String_scanner = -> x do
      require 'strscan'
      ::StringScanner.new x
    end

    system_lib = sidesys[ :System ]

    System = -> do
      system_lib[].services
    end
  end

  # ==

  ACHIEVED_ = true
  Brazen_ = Autoloader_.require_sidesystem :Brazen
  Action_ = Brazen_::Action
  Home_ = self
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  KEEP_PARSING_ = true
  Model_ = Brazen_::Model
  NIL_ = nil
  UNABLE_ = false
end
