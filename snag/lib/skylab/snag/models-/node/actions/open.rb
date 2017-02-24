module Skylab::Snag

  class Models_::Node

    class Actions::Open

      def definition ; [

        :flag, :property, :try_to_reappropriate,

        :property, :downstream_reference,

        :required, :property, :upstream_reference,

        :required, :glob, :property, :message,
      ] end

      def initialize
        extend NodeRelatedMethods, ActionRelatedMethods_
        init_action_ yield
        @downstream_reference = nil  # #[#026] (and:)
        @try_to_reappropriate = nil
      end

      def execute
        if resolve_node_collection_
          __via_node_collection
        end
      end

      def __via_node_collection

        _cx = build_choices_by_ do |o|
          o._snag_downstream_reference_ = @downstream_reference
          o._snag_try_to_reappropriate_ = @try_to_reappropriate
        end

        @_node_collection_.edit(
          :using, _cx,
          :add, :node,
            :append, :tag, :open,
            :append, :message, @message,
          & _listener_ )
      end

      Try_to_reappropriate = -> node_, sess, invo_rsx, & x_p do  # 1x

        node = Home_::Models_::NodeCollection::Magnetics_::
            ReappropriablestNode_via_Arguments.call(
          sess.entity_upstream,
          invo_rsx,
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
