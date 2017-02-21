module Skylab::Snag

  class Models_::Node

    Home_._NO_MORE_COMMON_ACTION
    class Actions::Create < Common_Action_

      def definition ; [

                   :property, :downstream_identifier,
        :required, :property, :upstream_identifier,
        :required, :argument_arity, :one_or_more, :property, :message
      ] end

      def execute
        if resolve_node_collection_
          __via_node_collection
        end
      end

      def __via_node_collection

        self._NO_MORE_ARGUMENT_BOX
        bx = @argument_box

        @_node_collection_.edit(

          :using, bx,
          :add, :node,
            :append, :message, bx.fetch( :message ),
          & _listener_ )
      end
    end

    class Actions::Open < Common_Action_  # egads as long as it is found here :+#stowaway

      edit_entity_class(

            :flag, :property, :try_to_reappropriate,
                   :property, :downstream_identifier,
        :required, :property, :upstream_identifier,
        :required, :argument_arity, :one_or_more, :property, :message
          # (arity thing is experiment for the future)
      )

      def execute
        if resolve_node_collection_
          __via_node_collection
        end
      end

      def __via_node_collection

        self._NO_MORE_ARGUMENT_BOX
        bx = @argument_box

        @_node_collection_.edit(

          :using, bx,
          :add, :node,
            :append, :tag, :open,
            :append, :message, bx.fetch( :message ),
          & _listener_ )
      end

      Try_to_reappropriate = -> node_, sess, & x_p do

        node =
        Models_::NodeCollection::Magnetics_::
            ReappropriablestNode_via_Arguments.call(
          sess.entity_upstream,
          & x_p )

        sess.reset_the_entity_upstream

        if node
          Reappropriate___[ node, node_, & x_p ]
        else
          node_
        end
      end

      class Reappropriate___

        class << self
          def [] * a, & x_p
            new( * a, & x_p ).execute
          end
        end  # >>

        def initialize node, node_, & x_p
          @node = node
          @node_ = node_
          @_x_p = x_p
        end

        def execute

          ok = __reappropriate_identifier
          ok &&= __carry_over_old_message
          ok && __finish
        end

        def __reappropriate_identifier

          @node_.edit(

            :via, :object,
            :set, :identifier, @node.ID,
            & @_x_p )
        end

        def __carry_over_old_message

          st = @node.body.to_row_stream_

          row = st.gets
          if row
            __etc row, st
          else
            @_x = @node
            ACHIEVED_
          end
        end

        def __etc row, st

          s = "( #was: #{ row.get_business_substring }"
          s_a = [ s ]

          begin
            row = st.gets
            row or break
            s_ = row.get_business_substring
            s_ or break  # blank line
            s = s_
            s_a.push s
            redo
          end while nil

          s.concat " )"

          ok = @node_.edit(
            :append, :message, s_a,
            & @_x_p )

          if ok
            @_x = @node_
            ACHIEVED_
          else
            ok
          end
        end

        def __finish
          @_x
        end
      end
    end
  end
end

# :+#tombstone: `list` method was original conception point of #doc-point [#sl-102])
