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

        Require_fields_lib_[]

        @stack_frame_ = fo_frame
        @_si = Here_::Scope_Index.new fo_frame
        @_primitivesque_appropriation_op_box = @_si.release_POOB__
        ___index_stateds
        # (don't freeze because some parts are 'released')
        self
      end

      def ___index_stateds

        # this is where we partition into o.p vs arguments

        all = []
        @_arguments = nil
        @_bespokes_to_add_to_op = nil
        @_did_one_glob = false
        @_k = nil
        @_my_set_symbol_via_name_symbol = {}
        @_scope_node_identifier = nil
        @_scope_node_ticket = nil

        h = @_si.hash_for_scope_node_identifier_via_name_symbol__
        st = @stack_frame_.to_defined_formal_parameter_stream__

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

        remove_instance_variable :@_did_one_glob
        remove_instance_variable :@_k
        remove_instance_variable :@_parameter
        remove_instance_variable :@_scope_node_identifier
        remove_instance_variable :@_scope_node_ticket
        NIL_
      end

      # -- is exactly [#015] figure 1. flowchart for expression of para..

      def __when_bespoke

        if @_parameter.is_provisioned
          @_my_set_symbol_via_name_symbol[ @_k ] = :_provisioned_
        else
          @_my_set_symbol_via_name_symbol[ @_k ] = :_bespoke_
          __express_bespoke_in_interface
        end
        NIL
      end

      def __express_bespoke_in_interface

        sym = @_parameter.singplur_category_of_association
        if sym
          if :singular_of == sym
            __when_the_singular_bespoke
          end
        else
          __when_nonsingplur_bespoke
        end
        NIL
      end

      def __when_the_singular_bespoke

        if Field_::Is_required[ @_parameter ]
          if @_did_one_glob
            # (it would be nice if help screen screen explained the
            # requiredness and the plurality of this parameter)
            _add_this_bespoke_to_the_op
          else
            _occupy_the_glob_slot
          end
        else
          # (it would be nice if help screen explained the plurality of this)
          _add_this_bespoke_to_the_op
        end
        NIL
      end

      def __when_nonsingplur_bespoke

        if Field_::Is_required[ @_parameter ]
          Field_::Can_be_more_than_one[ @_parameter.argument_arity ] && self._SANITY_see_flowchart  # #todo
          ( @_arguments ||= [] ).push @_parameter
        else
          _add_this_bespoke_to_the_op
        end
        NIL
      end

      def _add_this_bespoke_to_the_op
        ( @_bespokes_to_add_to_op ||= [] ).push @_parameter ; nil
      end

      def __release_bespokes_to_add_to_op
        remove_instance_variable :@_bespokes_to_add_to_op
      end

      # --

      def __when_appropriation

        if @_parameter.is_provisioned
          self._ENJOY
        end

        @_scope_node_ticket = @_si.scope_node_ @_scope_node_identifier

        _ = Node_ticket_4_category_[ @_scope_node_ticket ]

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

        @_asc = @_scope_node_ticket.association

        if :zero == @_asc.argument_arity

          # for [#044] flags, we now say that it is meaningless to speak of
          # the "requiredness" of a flag (in this modality). always o.p

          _is_argumentish = false  # only for coverage

        elsif Field_::Is_required[ @_parameter ]

          _is_argumentish = true
        end

        if _is_argumentish

          send SINGPLUR___.fetch @_asc.singplur_category

        else

          # near [#015] note B, not sure to what extent we want to allow
          # the operation definition to re-define the formal node with
          # all the parameter metadata it's capable of expressing. for e.g
          # changing the argument arity seems wrong, but changing the desc
          # seems ok.

          @_parameter.description_proc and self._CUSTOMIZED_DESC_NOT_IMPLEMENTED
        end

        remove_instance_variable :@_asc
        NIL_
      end

      SINGPLUR___ = {
        :plural_of => :__maybe_reindex_plurof_as_argument,
        nil => :__maybe_reindex_appropriated_as_argument,
      }

      def __maybe_reindex_appropriated_as_argument

        @_primitivesque_appropriation_op_box.remove @_k  # :#spot-3
        _reindex_appropriated_as_argument
      end

      def __maybe_reindex_plurof_as_argument

        if @_did_one_glob
          self._K
        else
          _occupy_the_glob_slot
        end
      end

      def _occupy_the_glob_slot

        # express a singplur pair as a "glob"-type trailing formal argument.
        # use variously the singular AND plural surface form based on what
        # we are doing: with the example singplur pair "path"/"paths",
        #
        #   • in the expression of syntax use the singular
        #     ("<path> [<path> [..]]")
        #
        #   • internally when referencing this component in indexes
        #     use the plural (`paths`)
        #
        #   • when writing to an ivar use the plural `@paths`
        #
        # (the above is now explained in further depth in [#ac-026])

        @_did_one_glob = true

        if @_scope_node_identifier  # then appropriated
          __occupy_the_glob_slot_when_appropriated
        else
          __occupy_the_glob_slot_when_bespoke
        end
        NIL
      end

      def __occupy_the_glob_slot_when_appropriated

        asc = @_asc
        plur_sym = asc.name_symbol
        sing_sym = asc.singplur_referent_symbol
        asc = nil

        _d = @_si.scope_node_identifier_via_node_name_symbol__ sing_sym
        mixed_name = @_si.scope_node_( _d ).name

        @_parameter = @_parameter.dup_by do |o|

          plur_sym == o.name_symbol or self._SANITY  # #todo

          o.name = mixed_name

          sym = o.argument_arity

          if :one == sym
            o.argument_arity = :one_or_more
          else
            :zero_or_more == sym || self._COVER_ME  # #todo
          end
        end

        @_primitivesque_appropriation_op_box.remove sing_sym

        _reindex_appropriated_as_argument
      end

      def _reindex_appropriated_as_argument

        _d = ( @_arguments ||= [] ).length

        ( @node_ticket_index_via_argument_index__ ||= [] )[ _d ] =
          @_scope_node_identifier

        @_arguments.push @_parameter ; nil
      end

      def __occupy_the_glob_slot_when_bespoke

        # a bespoke that is taking the glob spot must be the singular of
        # a singplur pair. for aesthetics we want the singular moniker to
        # appear (`<file> [<file> [..]]` not `<files> [<files> [..]]`).
        # also, per [#ac-026] the singular has most of the definition in it
        # (i.e description) so that's the one we want. but to get it to show
        # the ellipsis:

        @_parameter = @_parameter.dup_by do |o|
          o.argument_arity = :one_or_more
        end
        ( @_arguments ||= [] ).push @_parameter
        NIL
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
          Common_::Stream.via_nonsparse_array a
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
        TREAT_AS_APPROPRIATED___.fetch _
      end

      TREAT_AS_APPROPRIATED___ = {
        _provisioned_: false,
        _appropriated_: true,
        _bespoke_: false,
        _operation_dependency_: true,
      }

      def scope_index_  # e.p #hook-out (and closer)
        @_si
      end

      attr_reader(
        :node_ticket_index_via_argument_index__,
        :stack_frame_,
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

      # ==
    end
  end
end
