module Skylab::Autonomous_Component_System

  module Operation

    class Formal_  # used by [ze] too

      # the "formal" part of the operation is that which is defined by the
      # association-like DSL expression. this data is wrapped by this node
      # only in the interest of compartmentalization - it (as associations)
      # is [#002]:dt3 ephemeral. more in [#009].

      class << self

        def method_name_for_symbol sym
          :"__#{ sym }__component_operation"
        end

        def via_method_name_and_selection_stack m, a
          new.___init_via( m, a ).execute
        end

        private :new
      end  # >>

      def ___init_via m, a
        @_method_name = m
        @operation_is_available = true
        @selection_stack = a
        self
      end

      # --

      def deliverable_via_argument_stream arg_st, & pp
        deliverable_ Request_for_Deliverable_[
          @selection_stack,
          nil,  # no modifiers for such a call
          arg_st,
          pp ]
      end

      def deliverable_ dreq
        @_reifier.produce_deliverable_ dreq
      end

      # --

      def execute

        x = _ACS.send @_method_name do | * x_a |

          st = Callback_::Polymorphic_Stream.via_array x_a
          begin
            send :"__accept__#{ st.gets_one }__meta_component", st
            st.no_unparsed_exists and break
            redo
          end while nil
          NIL_
        end

        if x.respond_to? :call
          @_reifier = Here_::Proc_based_Implementation___.new x, self
        else

          _pfoz = x::PARAMETERS  # NOTE - `respond_to?` :parameters whenever
          @_reifier = Here_::NonProc_based_Implementation___.new _pfoz, x, self
        end

        self
      end

      def _ACS
        @selection_stack.fetch( -2 ).ACS
      end

      def ___accept_proc_as_implementation x
        NIL_
      end

      # --

      def __accept__is_available__meta_component st
        @operation_is_available = st.gets_one
        NIL_
      end

      attr_reader :operation_is_available

      def __accept__parameter__meta_component st

        @box ||= Callback_::Box.new
        ACS_::Parameter.interpret_into_via_passively__ @box, st
        NIL_
      end

      attr_reader :box

      def name
        @selection_stack.fetch( -1 )
      end

      attr_reader :selection_stack  # [ze]
    end
  end
end
