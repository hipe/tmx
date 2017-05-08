module Skylab::TanMan

  class Models_::Node

    class Magnetics_::UpdateAttributes_via_Hash_and_Node < Common_::MagneticBySimpleModel

      # (this is written as though yadda but yadda. single client, called inline. #cov3.2)

      def initialize
        super  # hi.
      end

      attr_writer(
        :attributes_hash,
        :listener,
        :node,
      )

      def execute

        a_list = @node.node_stmt.attr_list.content

        if ! a_list.prototype_
          a_list.prototype_ = Memoized___[] || Memoize___[ @node.node_stmt ]
        end

        add_a = []
        change_a = []

        a_list.update_attributes_ @attributes_hash,

          -> s, x { add_a.push [ s, x ] },
          -> s, x, x_ { change_a.push [ s, x, x_ ] }

        @listener.call :info, :updated_attributes do
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
          :node, @node,
          :adds, add_a,
          :changes, change_a,
        )
      end

      Updated_Attributes___ = Common_::Event.prototype_with(
        :updated_attributes,
        :node, nil,
        :adds, nil, :changes, nil,
        :ok, true,
      ) do |y, o|
        o.dup.extend( Express___ ).__express_into_under_ y, self
      end

      module Express___

        def __express_into_under_ y, expag
          @line_yielder = y ; @expression_agent = expag ; execute
        end

        def execute

          predicate_strings = []

          if @adds.length.nonzero?
            predicate_strings.push __say_adds
          end

          if @changes.length.nonzero?
            predicate_strings.push __say_changes
          end

          buff = ""

          o = self
          @expression_agent.calculate do
            buff << "on node #{ component_label o.node.get_node_label_ }"
            buff << " #{ predicate_strings * " and " }"
          end

          @line_yielder << buff
        end

        def __say_adds
          o = self
          @expression_agent.simple_inflection do

            buff = "" ;  same = ', '
            oxford_join buff, Scanner_[ o.adds ], same, same do |(k_s, v_s)|
              "#{ k_s }=#{ v_s }"
            end

            "added #{ n "attribute" }: [ #{ buff } ]"
          end
        end

        def __say_changes
          o = self
          @expression_agent.simple_inflection do

            buff = "" ; same = " and "
            oxford_join buff, Scanner_[ o.changes ], same, same do |(k_s, old, new)|
              "changed #{ k_s } from #{ mixed_primitive old } to #{ mixed_primitive new }"
            end
          end
        end
      end

      # ==
      # ==
    end
  end
end
# #history-A.1: re-packaged was was once "node controller" as update attributes magnetic
