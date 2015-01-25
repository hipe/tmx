module Skylab::TanMan

  class Models_::Node

    class Controller__

      # this is an experimental overflow spot for auxiliary
      # operations we don't want in the main model node.

      def initialize node, dotfile_controller
        @df_c = dotfile_controller
        @node = node
        @on_event_selectively = node.handle_event_selectively
      end

      def update_attributes attrs  # does not save file

        a_list = @node.node_stmt.attr_list.content

        if ! a_list._prototype
          a_list._prototype = Memoized___[] || Memoize___[ @node.node_stmt ]
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

        Updated_Attributes___.new_with(
          :node_stmt, @node.node_stmt,
          :add_a, add_a,
          :change_a, change_a )

      end

      Updated_Attributes___ = Callback_::Event.prototype_with :updated_attributes,

          :node_stmt, nil, :add_a, nil, :change_a, nil, :ok, true do | y, o |

        pred_a = []

        if o.add_a.length.nonzero?

          _s_a = o.add_a.map do | k_s, v_s |
            "#{ k_s }=#{ v_s }"
          end.join ', '

          pred_a.push "added attribute#{ s o.add_a }: [ #{ _s_a } ]"
        end

        if o.change_a.length.nonzero?

          _s_a = o.change_a.map do | k_s, old, new |
            "#{ k_s } from #{ val old } to #{ val new }"
          end.join ' and '

          pred_a.push "changed #{ _s_a }"
        end

        y << "on node #{ lbl o.node_stmt.label } #{ pred_a * ' and ' }"
      end

      class Normalize_name

        Callback_::Actor.call self, :properties,
          :ent,
          :arg

        def execute
          @arg
        end
      end
    end
  end
end
