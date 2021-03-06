module Skylab::Snag

  class Models_::NodeCollection

    module ExpressionAdapters::ByteStream

      class Magnetics_::NodeReplacement_via_Session < Common_::Monadic

        def initialize o
          @session = o
        end

        def execute  # ->

            o = @session
            o.write_each_node_until_the_subject_node_is_found
            o.write_the_subject_node
            o.write_the_remaining_nodes

        end  # <-
      end
    end
  end
end
