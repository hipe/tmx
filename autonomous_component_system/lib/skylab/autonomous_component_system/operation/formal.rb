module Skylab::Autonomous_Component_System

  module Operation

    class Formal  # 1x [mt] 1x here

      # the "formal" part of the operation is that which is defined by the
      # association-like DSL expression. this data is wrapped by this node
      # only in the interest of compartmentalization - it (as associations)
      # is [#002]:DT3 ephemeral. more in [#009].

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

                if ! ss.last  # kind of nasty [#030]: it is convenient for
                  # fuzzy lookup to be told what the actual name (symbol)
                  # is that was resolved, otherwise `sym` is inaccessible.
                  ss[ -1 ] = Callback_::Name.via_variegated_symbol sym
                end

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

      def deliverable_as_is & oes_p  # for [#ac-027]

        _pp = -> _ do
          oes_p
        end

        _ = deliverable_ Request_for_Deliverable_[
          @selection_stack,
          nil,  # no modifiers
          nil,  # no arg stream - the formal op must specify its params
          _pp ]

        _
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

      def __accept__unavailability__meta_component st
        @_unavailability_proc = st.gets_one
        NIL_
      end

      attr_reader :_unavailability_proc

      def unavailability
        p = _unavailability_proc
        if p
          p[ self ]
        end
      end

      def __accept__parameter__meta_component st

        @box ||= Callback_::Box.new
        ACS_::Parameter.interpret_into_via_passively__ @box, st
        NIL_
      end

      attr_reader :box

      def __accept__parameters_from__meta_component st
        @parameters_from_proc_ = st.gets_one
        NIL_
      end

      attr_reader :parameters_from_proc_

      def name_symbol  # [ze]
        @selection_stack.fetch( -1 ).as_variegated_symbol
      end

      def name
        @selection_stack.fetch( -1 )
      end

      attr_reader :selection_stack  # [ze]

      def reifier  # for now, for [ze] to spy on module
        @_reifier
      end

      def associationesque_category
        :formal_operation
      end
    end
  end
end
