module Skylab::Brazen

  class CLI_Support::Table::Actor  # see [#096.B]

    class << self

      same = -> * x_a, & p do
        o = new( & p )
        o._init_arg_upstream_and_depdendencies x_a
        o._execute
      end

      define_method :[], same

      define_method :call, same

      def curry * x_a
        o = new
        o._init_arg_upstream_and_depdendencies x_a
        o._produce_self_as_curry
      end
    end  # >>

    def initialize

      block_given? and self._COVER_ME

      @_deps = nil
      @_down_st = nil
    end

    def _init_arg_upstream_and_depdendencies x_a

      _init_argument_upstream x_a

      o = Home_.lib_.plugin::Dependencies.new self

      o.roles = ROLES__
      o.emits = EVENTS__
      o.index_dependencies_in_module Strategies___

      @_deps = o
    end

    def dup  # see [#.I]

      otr = self.class.new
      otr.__init_dup @_deps
      otr
    end

    def __init_dup deps

      if deps
        @_deps = deps.dup self
      end

      NIL_
    end

    Autoloader_[ ( Field_Strategies_ = ::Module.new ), :boxxy ]

    Autoloader_[ ( Row_Strategies_ = ::Module.new ), :boxxy ]

    Autoloader_[ ( Strategies___ = ::Module.new ), :boxxy ]

    def curry * x_a, & x_p
      otr = dup
      otr._init_argument_upstream x_a, & x_p
      otr._produce_self_as_curry
    end

    def _produce_self_as_curry

      ok = _process_arguments
      if ok
        freeze
      else
        ok
      end
    end

    as_curry_call = -> * x_a, & x_p do

      otr = dup
      otr._init_argument_upstream x_a, & x_p
      otr._execute
    end

    define_method :[], as_curry_call

    define_method :call, as_curry_call

    def _init_argument_upstream x_a, & x_p

      block_given? and self._COVER_ME

      @_argument_upstream = Callback_::Polymorphic_Stream.via_array x_a

      NIL_
    end

    def _execute
      if @_argument_upstream.no_unparsed_exists
        NIL_  # as covered
      else
        __execute_when_some_arguments
      end
    end

    def __execute_when_some_arguments

      kp = __process_argument_or_arguments
      kp &&= __normalize_fields
      kp &&= __resolve_downstream
      kp &&= __resolve_upstream
      kp && __interpret_and_express_table
    end

    def __process_argument_or_arguments

      st = @_argument_upstream

      x = st.gets_one
      if st.no_unparsed_exists
        __receive_mixed_user_data_upstream x
        KEEP_PARSING_
      else
        st.backtrack_one  # LOOK
        _process_arguments
      end
    end

    def __receive_mixed_user_data_upstream x  # (see next method)

      @_deps[ :mixed_user_data_upstream_receiver ].
        receive_mixed_user_data_upstream x

      NIL_
    end

    def _process_arguments

      @_deps.process_polymorphic_stream_fully @_argument_upstream
    end

    ROLES__ = []
    ROLES__.push :mixed_user_data_upstream_receiver

    def receive_sanitized_user_row_upstream x  # (hookback from prev method)
      @_row_upstream = x
      NIL_
    end

    def __normalize_fields

      _x = @_deps[ :field_normalizer ].receive_normalize_fields
      _x or fail
      KEEP_PARSING_
    end

    ROLES__.push :field_normalizer

    def __resolve_downstream

      if @_down_st
        KEEP_PARSING_
      else

        x = @_deps[ :downstream_context_producer ].produce_downstream_context
        x or fail

        @_down_st = x

        KEEP_PARSING_
      end
    end

    ROLES__.push :downstream_context_producer

    def __resolve_upstream

      # if we didn't get one from the arguments at this point, it's strange

      if @_row_upstream
        KEEP_PARSING_
      else
        fail
      end
    end

    def __interpret_and_express_table

      @_deps[ :downstream_context_receiver ].
        receive_downstream_context @_down_st

      @_deps[ :user_data_upstream_receiver ].
        receive_user_data_upstream @_row_upstream
    end

    ROLES__.push :downstream_context_receiver
    ROLES__.push :user_data_upstream_receiver
    ROLES__.freeze

    EVENTS__ = []
    EVENTS__.push :argument_bid_for
    EVENTS__.freeze

    # ~ service API

    def dependencies  # #experimental
      @_deps
    end

    module Strategy_
      p = nil
      Has_arguments = -> cls do
        if ! p
          p = Home_.lib_.plugin::Dependencies::Argument::Has_arguments
        end

        p[ cls ]
      end
    end

    DEFAULT_STRINGIFIER_ = -> x do
      x.to_s  # nil OK, false OK
    end

    LEFT_GLYPH_ = '| '
    RIGHT_GLYPH_ = ' |'
    SEP_GLYPH_ = ' | '

    Home_ = ::Skylab::Brazen  # will prolly move up
    Table_Impl_ = self
  end
end
# :#historical-note: this node's ancestor became one of its children
