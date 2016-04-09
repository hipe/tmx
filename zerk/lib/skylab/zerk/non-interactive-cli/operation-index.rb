module Skylab::Zerk

  class NonInteractiveCLI

    class Operation_Index  # 1x. name implements interface

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

        @_arguments = nil
        @__bespoke_a = nil
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

          @_k = @_parameter.name_symbol
          @_scope_node_identifier = h[ @_k ]

          if @_scope_node_identifier
            __when_appropriation
          else
            __when_bespoke
          end

          redo
        end while nil

        remove_instance_variable :@_k
        remove_instance_variable :@_parameter
        remove_instance_variable :@_scope_node_identifier
        remove_instance_variable :@_scope_node_ticket
        NIL_
      end

      def __when_bespoke

        ( @__bespoke_a ||= [] ).push @_parameter

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

          @_primitivesque_appropriation_op_box.remove(  # :#spot-3
            @_scope_node_ticket.name_symbol )

          a = ( @_arguments ||= [] )
          _a_ = ( @node_ticket_index_via_argument_index__ ||= [] )
          _a_[ a.length ] = @_scope_node_identifier

          a.push @_parameter

        else
          self._COVER_ME_readme  # in contrast to [#] note B, we might want
          #  to allow customization (overriding) of the description..
        end
      end

      # -- all #as an operation index

      def evaluation_proc_for_ pbc

        # the following method (#here) produces a stream that produces a
        # sequence of parameters. assume that the proc produced by the
        # *subject* method will be called with each parameter from this
        # stream in its order. all parameters are either appropriated
        # or bespoke. when they are appropriated, the store is the ACS
        # tree. otherwise (and they are bespoke) the store is the XXX.

        hi = Home_::Invocation_::Evaluation.proc_for_ pbc, self

        -> par do
          # (hi.)
          hi[ par ]
        end
      end

      def to_PVS_parameter_stream_  # :#here

        # for [#ac-028]#"Head parse" - we use this hack-like) maneuver to
        # pass values into the call that don't live in the ACS tree, namely:

        a = @__bespoke_a
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

      def arguments_
        @_arguments
      end

      def fetcher_proc_for_set_symbol_via_name_symbol_
        method :set_symbol_via_name_symbol_
      end

      def set_symbol_via_name_symbol_ sym

        set_sym = @_my_set_symbol_via_name_symbol[ sym ]
        if set_sym
          set_sym
        elsif is_appropriated_ sym
          :_scope_node_not_appropriated_
        else
          self._COVER_ME_not_found
        end
      end

      def is_appropriated_ k
        @_si.has_ k
      end

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

        def fetcher_proc_for_set_symbol_via_name_symbol_
          method :_set_symbol_via_name_symbol
        end

        def is_appropriated_ k
          @_si.has_ k or self._SANITY
          true
        end

        def _set_symbol_via_name_symbol k

          _nt = @_si.node_ticket_via_node_name_symbol_ k
          ETC___.fetch _nt.node_ticket_category
        end

        ETC___ = {
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
