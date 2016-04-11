module Skylab::Zerk

  class NonInteractiveCLI

    class Operation_Index  # 1x. name implements interface

      # exactly the [#015]#algorithm.

      class << self

        def new_from_top__ fo_frame
          ___new_empty.__init_for_top fo_frame
        end

        alias_method :___new_empty, :new
        undef_method :new
      end  # >>

      def dup_for_recursion_ fo
        Pared_Down_for_Recursion___.new fo, self
      end

      def initialize
        NOTHING_  # (hi.)
      end

      def __init_for_top fo_frame

        @__fo_frame = fo_frame
        @_si = Here_::Scope_Index.new fo_frame
        @_primitivesque_appropriation_op_box = @_si.__release_POOB
        ___index_stateds
        # (don't freeze because some parts are 'released')
        self
      end

      def ___index_stateds

        # this is where we partition into o.p vs arguments

        Require_field_library_[]

        all = []
        @_arguments = nil
        @_bespokes_to_add_to_op = nil
        @_k = nil
        @_my_set_symbol_via_name_symbol = {}
        @_scope_node_identifier = nil
        @_scope_node_ticket = nil

        h = @_si.hash_for_scope_node_identifier_via_name_symbol__
        st = @__fo_frame.to_defined_formal_parameter_stream__

        begin
          @_parameter = st.gets
          @_parameter or break

          all.push @_parameter

          @_k = @_parameter.name_symbol
          @_scope_node_identifier = h[ @_k ]

          if @_scope_node_identifier
            __when_appropriation
          else
            __when_bespoke
          end

          redo
        end while nil

        @__all_stateds = ( all if all.length.nonzero? )

        remove_instance_variable :@_k
        remove_instance_variable :@_parameter
        remove_instance_variable :@_scope_node_identifier
        remove_instance_variable :@_scope_node_ticket
        NIL_
      end

      def __when_bespoke

        @_my_set_symbol_via_name_symbol[ @_k ] = :_bespoke_

        if Field_::Is_required[ @_parameter ]
          ( @_arguments ||= [] ).push @_parameter
        else
          ( @_bespokes_to_add_to_op ||= [] ).push @_parameter
        end
        NIL_
      end

      def __release_bespokes_to_add_to_op
        remove_instance_variable :@_bespokes_to_add_to_op
      end

      def __when_appropriation

        @_scope_node_ticket = @_si.scope_node_ @_scope_node_identifier

        _ = Node_ticket_3_category_[ @_scope_node_ticket ]

        m = WHEN_APPROPRIATION___.fetch _

        if m
          send m
        end
        NIL_
      end

      WHEN_APPROPRIATION___ = {
        operation: :__when_operation_dependency,
        primitivesque: :__when_primitivesque_appropriation,
      }

      def __when_operation_dependency  # [#] note C

        @_my_set_symbol_via_name_symbol[ @_k ] = :_operation_dependency_
        NIL_
      end

      def __when_primitivesque_appropriation

        @_my_set_symbol_via_name_symbol[ @_k ] = :_appropriated_

        if Field_::Is_required[ @_parameter ]

          __reindex_appropriated_as_argument

        else

          # near [#015] note B, not sure to what extent we want to allow
          # the operation definition to re-define the formal node with
          # all the parameter metadata it's capable of expressing. for e.g
          # changing the argument arity seems wrong, but changing the desc
          # seems ok.

          @_parameter.description_proc and self._CUSTOMIZED_DESC_NOT_IMPLEMENTED
        end
        NIL_
      end

      def __reindex_appropriated_as_argument

        @_primitivesque_appropriation_op_box.remove(  # :#spot-3
          @_scope_node_ticket.name_symbol )

        a = ( @_arguments ||= [] )
        _a_ = ( @node_ticket_index_via_argument_index__ ||= [] )
        _a_[ a.length ] = @_scope_node_identifier

        a.push @_parameter ; nil
      end

      # -- readers

      def evaluation_proc_for_ pbc  # #as o.i

        # the following method (#here) produces a stream that produces a
        # sequence of parameters. assume that the proc produced by the
        # *subject* method will be called with each parameter from this
        # stream in its order. all parameters are either appropriated
        # or bespoke. when they are appropriated, the store is the ACS
        # tree. otherwise (and they are bespoke) the temporary store is
        # the "floaty structure".

        hi = Home_::Invocation_::Evaluation.proc_for_ pbc, self

        -> par do
          # (hi.)
          hi[ par ]
        end
      end

      def to_PVS_parameter_stream_  # #as o.i

        # unlike in [ac], we provide that stateds either do or don't refer
        # to scope nodes. whether the values of these nodes live in the ACS
        # tree (as appropriateds do) or they live in a "floaty structure"
        # (as bespokes do), these values must each be written to the
        # parameter store so that our operation implementation is given the
        # values of its stated uniformly (imagine a proc). so the below
        # formal set will work in conjunction with the above method :#here.
        # more at [#015]#"stated values".

        a = @__all_stateds
        if a
          Callback_::Stream.via_nonsparse_array a
        end
      end

      def release_primitivesque_appropriation_op_box__
        remove_instance_variable :@_primitivesque_appropriation_op_box
      end

      def root_frame__
        @_si.the_root_frame__
      end

      def arguments_  # niCLI only
        @_arguments
      end

      def fetcher_proc_for_reception_set_symbol_via_name_symbol_  # #as o.i
        method :niCLI_reception_set_symbol_for_
      end

      def niCLI_reception_set_symbol_for_ sym

        set_sym = @_my_set_symbol_via_name_symbol[ sym ]
        if set_sym
          set_sym
        else
          # (hi.)
          if @_si.has_ sym
            :_scope_node_not_appropriated_
          else
            self._COVER_ME_node_name_symbol_not_found_anywhere_in_index
          end
        end
      end

      def is_appropriated_ k  # #as o.i,

        # tells #spot-4 when we need to write *from* ACS tree *to* param store)

        _ = @_my_set_symbol_via_name_symbol.fetch k  # until not..
        OVERKILL_SANITY_CHECK___.fetch _
      end

      OVERKILL_SANITY_CHECK___ = {
        _appropriated_: true,
        _bespoke_: false,
        _operation_dependency_: true,
      }

      def scope_index_  # e.p #hook-out (and closer)
        @_si
      end

      attr_reader(
        :node_ticket_index_via_argument_index__,
      )

      # ==

      class Pared_Down_for_Recursion___

        # for now, if we don't need to let's not even bother indexing the
        # operation dependencies at all. they must LA LA so LA LA

        def initialize _fo, otr
          @_si = otr.scope_index_
        end

        def dup_for_recursion_ _fo
          self.class.new _fo, self
        end

        def evaluation_proc_for_ pbc
          hi = Home_::Invocation_::Evaluation.proc_for_ pbc, self
          -> par do
            hi[ par ]
          end
        end

        def fetcher_proc_for_reception_set_symbol_via_name_symbol_
          method :_set_symbol_via_name_symbol
        end

        def is_appropriated_ k
          @_si.has_ k or self._SANITY
          true
        end

        def _set_symbol_via_name_symbol k

          _nt = @_si.node_ticket_via_node_name_symbol_ k
          SET_SYMBOL_WHEN___.fetch _nt.node_ticket_category
        end

        SET_SYMBOL_WHEN___ = {
          association: :_appropriated_,
          operation: :_operation_dependency_,
        }

        def scope_index_
          @_si
        end
      end
    end
  end
end