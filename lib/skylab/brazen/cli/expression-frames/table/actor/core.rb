module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor  # see [#096.B]

    class << self

      same = -> * x_a, & p do
        o = new( & p )
        o._load_strategies_and_receive_polymorphic_argument_array x_a
        o._execute
      end

      define_method :[], same

      define_method :call, same

      def curry * x_a
        o = new
        o._load_strategies_and_receive_polymorphic_argument_array x_a
        o._produce_self_as_curry
      end
    end  # >>

    def initialize & oes_p

      @_down_st = nil

      if oes_p
        @on_event_selectively = oes_p
      end
    end

    def _load_strategies_and_receive_polymorphic_argument_array x_a

      _receive_polymorphic_argument_array x_a

      disp = Brazen_.lib_.plugin::Pub_Sub::Dispatcher.new self, EMITS__

      disp.load_plugins_in_module Strategies___

      @_disp = disp

      NIL_
    end

    EMITS__ = []  # (added to throughout this file)

    Autoloader_[ ( Strategies___ = ::Module.new ), :boxxy ]

    def curry * x_a, & x_p
      otr = dup
      otr._receive_polymorphic_argument_array x_a, & x_p
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
      otr._receive_polymorphic_argument_array x_a, & x_p
      otr._execute
    end

    define_method :[], as_curry_call

    define_method :call, as_curry_call

    def initialize_dup _

      # when we dup self (for example as a curry to spawn & execute), we
      # will need to dup every strategy as well. some strategies will need
      # to freeze so we have to get all the building done atomically:

      disp = @_disp.dup do | disp_ |
        disp_.resources = self
        if @_disp.on_event_selectively
          self._SIGN_OFF_ON_THIS  # just assign it
        else
          disp_.on_event_selectively = nil  # from false
        end
      end

      @_disp = disp

      # once you have duped but before you do anything else, give strategies
      # chance to do any re-initialization that requires the whole graph.

      @_disp.accept :init_dup do | pu |
        pu.init_dup or fail
      end

      NIL_
    end

    EMITS__.push :init_dup

    def _receive_polymorphic_argument_array x_a, & x_p

      @_argument_upstream = Callback_::Polymorphic_Stream.via_array x_a
      if x_p
        @on_event_selectively = x_p
      end
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

      st = @_argument_upstream
      x = st.gets_one
      kp = if st.no_unparsed_exists
        @_disp.accept :receive_unsanitized_user_row_upstream do | pu |
          pu.receive_unsanitized_user_row_upstream x
        end
        KEEP_PARSING_
      else
        st.backtrack_one  # LOOK
        _process_arguments
      end
      kp &&= __resolve_downstream
      kp &&= __resolve_upstream
      kp && __interpret_and_express_table
    end

    EMITS__.push :receive_unsanitized_user_row_upstream

    def _process_arguments
      @_disp.accept :receive_unclassified_argument_stream do | pu |
        pu.receive_unclassified_argument_stream @_argument_upstream
      end
    end

    EMITS__.push :receive_unclassified_argument_stream

    def __resolve_downstream

      if @_down_st
        KEEP_PARSING_
      else
        x = nil
        @_disp.accept :produce_downstream_element do | pu |
          x = pu.produce_downstream_element
          ! x  # stop at the first one you find
        end
        if x
          @_down_st = x
          KEEP_PARSING_
        else
          STOP_PARSING_
        end
      end
    end

    EMITS__.push :produce_downstream_element

    def __resolve_upstream

      # if we didn't get one from the arguments at this point, it's strange

      if @_row_upstream
        KEEP_PARSING_
      end
    end

    def receive_sanitized_user_row_upstream x
      @_row_upstream = x
      NIL_
    end

    def __interpret_and_express_table

      disp = @_disp

      disp.accept :receive_downstream_element do | pu |
        pu.receive_downstream_element @_down_st
      end

      kp = KEEP_PARSING_
      st = @_row_upstream

      begin

        if st.no_unparsed_exists
          break
        end

        user_row_x = st.gets_one

        disp.accept :receive_user_row do | pu |  # #note-act-170

          kp = pu.receive_user_row user_row_x
          kp or break
        end

        kp or break

        redo
      end while nil

      if kp
        kp = disp.accept :receive_table do | pu |
          pu.receive_table
        end
      end
      if kp
        @_down_st.appropriate_result
      else
        kp
      end
    end

    EMITS__.push(
      :arity_for,  # used by a strategy
      :receive_downstream_element,
      :receive_user_row,
      :receive_table
    )

    # ~ support for strategies

    def dispatcher
      @_disp
    end

    Argumentative_strategy_class_ = -> do
      Table_Impl_::Strategy_::Argumentative
    end

    Simple_strategy_class_ = -> do
      Table_Impl_::Strategy_::Common
    end

    # (see how neutral we are:)

    LEFT_GLYPH_ = '| '
    RIGHT_GLYPH_ = ' |'
    SEP_GLYPH_ = ' | '

    Table_Impl_ = self
  end
end
# :#historical-note: this node's ancestor became one of its children
