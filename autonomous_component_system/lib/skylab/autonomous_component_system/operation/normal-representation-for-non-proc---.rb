module Skylab::Autonomous_Component_System

  module Operation

    class NormalRepresentation_for_NonProc___ < Normal_Representation_

      def initialize pfoz, x, fo
        @__classesque = x
        @formal_ = fo
        @__formals = pfoz
      end

      class Preparation < Preparation_

        def to_bound_call

          ok = check_availability_
          ok &&= __normalize
          ok && Callback_::Bound_Call[ NOTHING_, @_sess, :execute ]
        end

        def __normalize

          store = @parameter_store
          x = store.internal_store_substrate
          x.class.const_get( :PARAMETERS, false )  # sanity
          @_sess = x
          normalize_
        end
      end

      def to_defined_formal_parameter_stream_to_be_cached_

        self._TODO_easy_during_integration_README___

        # none of this is necessary anymore: [fi] formal attributes
        # look like this natively now..

        foz = @__formals
        op_h = foz.optionals_hash
        op_h ||= MONADIC_EMPTINESS_

        Callback_::Stream.via_nonsparse_array( foz.symbols ).map_by do |sym|

          Home_::Parameter.new_by_ do
            @name_symbol = sym
            @parameter_arity = if op_h[ sym ]
              :zero_or_one
            else
              :one
            end
          end
        end
      end

      def begin_parameter_store_ & call_handler

        Store___.new @__classesque.new( & call_handler )
      end

      attr_reader(
        :__classesque,
      )

      class Store___

        def initialize sess
          @_sess = sess
        end

        def accept_parameter_value x, par
          @_sess.send :"#{ par.name_symbol }=", x
          NIL_
        end

        def value_reader_proc

          # all formals came from us, so we should (?) never not know a value

          o = @_sess
          -> par do
            # experimental - we could require readers, but why?
            ivar = par.name.as_ivar
            if o.instance_variable_defined? ivar
              o.instance_variable_get ivar
            end
          end
        end

        def knownness_for par

          ivar = par.name.as_ivar
          if @_sess.instance_variable_defined? ivar
            Callback_::Known_Known[ @_sess.instance_variable_get ivar ]
          else
            Callback_::KNOWN_UNKNOWN
          end
        end

        def internal_store_substrate
          @_sess
        end
      end
    end
  end
end
