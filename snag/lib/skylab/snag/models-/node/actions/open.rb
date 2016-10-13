module Skylab::Snag

  class Models_::Node

    class Actions::Create < Common_Action_

      edit_entity_class(

                   :property, :downstream_identifier,
        :required, :property, :upstream_identifier,
        :required, :argument_arity, :one_or_more, :property, :message
      )

      def produce_result
        resolve_node_collection_then_
      end

      def via_node_collection_

        bx = @argument_box

        @node_collection.edit(

          :using, bx,
          :add, :node,
            :append, :message, bx.fetch( :message ),
          & handle_event_selectively )
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

      def produce_result
        resolve_node_collection_then_
      end

      def via_node_collection_

        bx = @argument_box

        @node_collection.edit(

          :using, bx,
          :add, :node,
            :append, :tag, :open,
            :append, :message, bx.fetch( :message ),
          & handle_event_selectively )
      end

      Try_to_reappropriate = -> node_, sess, & x_p do

        node =
        Home_::Models_::Node_Collection::Magnetics_::
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
