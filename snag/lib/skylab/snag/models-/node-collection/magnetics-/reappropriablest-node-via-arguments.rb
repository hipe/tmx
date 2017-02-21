module Skylab::Snag

  class Models_::NodeCollection

    class Magnetics_::ReappropriablestNode_via_Arguments < Common_::Dyadic

      # as an exercise we are sticking as close as is reasonable to a line-
      # by line transformation of the relevant "proto-sudocode" in [#038]

      def initialize nu, invo_rsx
        @__invocation_resources = invo_rsx
        @node_upstream = nu
      end

      def execute

        criteria_p = Models_::Node::Criteria.via_words_and_invocation_resources_( %w(
          the node is tagged with #done or #hole and has
          no extended content ),

          @__invocation_resources,

        ).to_proc

        memoized_node = nil
        memoized_node_number = nil

        @node_upstream.each do | node |

          criteria_p[ node ] or next

          if memoized_node
            d = node.number_of_times_tagged_with :was
            case d <=> memoized_node_number
            when -1
              memoized_node.reinitialize_copy_ node
              memoized_node_number = d
            when 0
              if node.ID < memoized_node.ID
                memoized_node = node.dup
              end
            end
          else
            memoized_node = node.dup
            memoized_node_number = node.number_of_times_tagged_with :was
          end
        end

        memoized_node
      end
    end
  end
end
