module Skylab::Autonomous_Component_System

  module Operation

    class Formal_  # 1x [mt] 1x here

      # the "formal" part of the operation is that which is defined by the
      # association-like DSL expression. this data is wrapped by this node
      # only in the interest of compartmentalization - it (as associations)
      # is [#002]:dt3 ephemeral. more in [#009].

      class << self

        def reader_of_formal_operations_by_method_in acs

          # we've decided that a "formal operation" includes the "selection
          # stack" involved in reaching it. so the reader (when successful)
          # cannot itself produce a full formal operation simply from a
          # symbolic name and an ACS. rather, the successful "read" results
          # in a proc which in turn will produce the formal operation when
          # passed a selection stack. whew!

          -> sym do

            m = :"__#{ sym }__component_operation"

            if acs.respond_to? m

              -> ss do
                _fo = new.___init_via m, ss
                _fo.execute
              end
            end
          end
        end

        private :new
      end  # >>

      def ___init_via m, ss
        @_method_name = m
        @operation_is_available = true
        @selection_stack = ss
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

      def __accept__description__meta_component st  # #during #milestone:4
        @description_proc = st.gets_one
        NIL_
      end

      attr_reader :description_proc

      def __accept__is_available__meta_component st
        @operation_is_available = st.gets_one
        NIL_
      end

      def __accept__unavailability_reason_tuple_proc__meta_component st
        # (it's a proc that produces a tuple of N symbols and one proc!)
        @unavailability_reason_tuple_proc = st.gets_one ; nil
      end

      attr_reader(
        :operation_is_available,
        :unavailability_reason_tuple_proc,
      )

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
# #pending-rename: promote to public [mt]
