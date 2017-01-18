module Skylab::Autonomous_Component_System

  module Operation

    class NormalRepresentation_for_NonProc___ < Normal_Representation_

      def initialize pfoz, x, fo
        @_classesque = x
        @formal_ = fo
        @__formals = pfoz
      end

      def desc_proc_
        if @_classesque.respond_to? :describe_into_under
          cls = @_classesque
          -> y do
            cls.describe_into_under y, self
          end
        end
      end

      class Preparation < Preparation_

        def to_bound_call

          ok = check_availability_
          ok &&= __normalize
          ok && Common_::BoundCall[ NOTHING_, @_sess, :execute ]
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

        @__formals.to_defined_attribute_stream
      end

      def begin_parameter_store_ & call_handler

        Store___.new @_classesque.new( & call_handler )
      end

      class Store___

        def initialize sess
          @_sess = sess
        end

        def accept_parameter_value x, par
          @_sess.send :"#{ par.name_symbol }=", x
          NIL_
        end

        def evaluation_proc
          method :evaluation_of
        end

        def evaluation_of par

          ivar = par.name.as_ivar

          if @_sess.instance_variable_defined? ivar

            Common_::Known_Known[ @_sess.instance_variable_get ivar ]
          else
            Common_::KNOWN_UNKNOWN
          end
        end

        def internal_store_substrate
          @_sess
        end

        def is_classesque
          true
        end
      end
    end
  end
end
