module Skylab::TanMan

  class Models_::Node

    class NodeController_

      # this is an experimental overflow spot for auxiliary
      # operations we don't want in the main model node.

      def initialize node, dotfile_controller
        @df_c = dotfile_controller
        @node = node
        @on_event_selectively = node.handle_event_selectively
      end

      def update_attributes attrs  # does not save file

        a_list = @node.node_stmt.attr_list.content

        if ! a_list.prototype_
          a_list.prototype_ = Memoized___[] || Memoize___[ @node.node_stmt ]
        end

        add_a = []
        change_a = []

        a_list._update_attributes attrs,

          -> s, x { add_a.push [ s, x ] },
          -> s, x, x_ { change_a.push [ s, x, x_ ] }

        @on_event_selectively.call :info, :updated_attributes do
          __build_updated_attributes_event add_a, change_a
        end
        ACHIEVED_
      end

      -> do
        x = nil
        Memoized___ = -> { x }
        Memoize___ = -> node_stmt do
          x = node_stmt.class.parse :a_list, 'a=b, c=d'  # [#054], [#071]
        end
      end.call

      def __build_updated_attributes_event add_a, change_a

        Updated_Attributes___.with(
          :node_stmt, @node.node_stmt,
          :adds, add_a,
          :changes, change_a,
        )
      end

      Updated_Attributes___ = Common_::Event.prototype_with(
        :updated_attributes,
        :node_stmt, nil,
        :adds, nil, :changes, nil,
        :ok, true,
      ) do |y, o|

        pred_a = []

        if o.adds.length.nonzero?

          _s_a = o.adds.map do | k_s, v_s |
            "#{ k_s }=#{ v_s }"
          end.join ', '

          pred_a.push "added attribute#{ s o.adds }: [ #{ _s_a } ]"
        end

        if o.changes.length.nonzero?

          _s_a = o.changes.map do | k_s, old, new |
            "#{ k_s } from #{ val old } to #{ val new }"
          end.join ' and '

          pred_a.push "changed #{ _s_a }"
        end

        y << "on node #{ lbl o.node_stmt.label } #{ pred_a * ' and ' }"
      end

      NormalKnownness_via_QualifiedKnownness_of_Name = -> qkn, ent, & oes_p do  # 1x

        # (placeholder for the idea)

        qkn.to_knownness
      end
    end
  end
end
