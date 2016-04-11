module Skylab::Zerk

  class NonInteractiveCLI

    class Scope_Index  # implements interface

      def initialize fo_frame

        @evaluations_cache_ = {}
        @_frame_index_via_node_identifier = []
        @_index_into_reverse_stack = 0
        @_primitivesque_appropriation_op_box = nil
        @_scope_node_identifier = nil

        node_tickets = []
        snivns = {}

        st = fo_frame.to_frame_stream_from_top_

        st.gets  # we're not doing anything with that one (right?)
        frame = st.gets  # there's always at least the root compound frame
        rev_stack = [ frame ]

        begin

          st_ = frame.to_referenceable_node_ticket_stream__
          begin

            @_scope_node_ticket = st_.gets
            @_scope_node_ticket or break

            @_scope_node_identifier = node_tickets.length

            snivns[ @_scope_node_ticket.name_symbol ] = @_scope_node_identifier

            node_tickets.push @_scope_node_ticket

            m = VIA_3_CAT___.fetch Node_ticket_3_category_[ @_scope_node_ticket ]
            # ..
            send m

            redo
          end while nil

          frame_ = st.gets
          frame_ or break
          frame = frame_
          rev_stack.push frame
          @_index_into_reverse_stack += 1
          redo
        end while nil

        @__root_frame = frame
        remove_instance_variable :@_index_into_reverse_stack
        remove_instance_variable :@_scope_node_identifier
        remove_instance_variable :@_scope_node_ticket

        @__reverse_stack = rev_stack
        @_scope_node_identifier_via_name_symbol = snivns
        @_scope_nodes = node_tickets
        NIL_
      end

      VIA_3_CAT___ = {
        operation: :__index_operation_node_ticket,
        primitivesque: :__index_primitivesque_node_ticket,
      }

      def __index_operation_node_ticket
        _index_as_scope_node
      end

      def __index_primitivesque_node_ticket

        _index_as_scope_node
        _bx = ( @_primitivesque_appropriation_op_box ||= Callback_::Box.new )

        # NOTE that this is a box only while we postpone the decision about
        # whether we allow a closer frame to define a node with the same
        # name as a node in a farther frame (in effect re-defining it). as
        # a box, when such a clobber happens *for a primitive*, it raises.

        _bx.add @_scope_node_ticket.name_symbol, @_scope_node_identifier
        NIL_
      end

      def __release_POOB
        remove_instance_variable :@_primitivesque_appropriation_op_box
      end

      def _index_as_scope_node

        @_frame_index_via_node_identifier[ @_scope_node_identifier ] =
          @_index_into_reverse_stack

        NIL_
      end

      # -- as a scope index

      def modality_frame_via_node_name_symbol_ k
        @__reverse_stack.fetch @_frame_index_via_node_identifier.fetch @_scope_node_identifier_via_name_symbol.fetch k
      end

      def node_ticket_via_node_name_symbol_ k
        @_scope_nodes.fetch @_scope_node_identifier_via_name_symbol.fetch k
      end

      attr_reader(
        :evaluations_cache_,
      )

      # --

      def scope_node_ d
        @_scope_nodes.fetch d
      end

      def the_root_frame__
        @__root_frame
      end

      def has_ k
        @_scope_node_identifier_via_name_symbol.key? k
      end

      def hash_for_scope_node_identifier_via_name_symbol__
        @_scope_node_identifier_via_name_symbol
      end
    end
  end
end
