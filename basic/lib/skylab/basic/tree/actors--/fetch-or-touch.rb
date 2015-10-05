module Skylab::Basic

  module Tree

    class Actors__::Fetch_or_touch

      Callback_::Actor.methodic self, :properties,

        :path_x,
        :x_p,
        :node,
        :fetch_or_touch,
        :leaf_node_payload_proc

      def initialize & edit_p

        @leaf_node_payload_proc = nil
        instance_exec( & edit_p )
      end

      def execute

        path_a = __some_normalized_path_a
        if path_a.length.zero?
          @node
        else
          __execute_when_some_path(
            Callback_::Polymorphic_Stream.via_array( path_a ),
            @node )
        end
      end

      def __execute_when_some_path scn, node

        begin

          slug = scn.gets_one

          node_ = node[ slug ]

          if ! node_ && :touch == @fetch_or_touch

            node_ = node.class.new slug
            node.add slug, node_

            p = if @leaf_node_payload_proc
              if scn.no_unparsed_exists
                @leaf_node_payload_proc
              end
            else
              @x_p
            end

            if p
              node_.set_node_payload p[]
            end
          end

          if node_
            if scn.unparsed_exists
              node = node_
              redo
            end
            x = node_
            break
          end

          if @x_p
            x = @x_p[]
            break
          end

          raise ::KeyError, "no such node: '#{ slug }'"
        end while nil
        x
      end

      def __some_normalized_path_a

        path_a = ::Array.try_convert @path_x
        if path_a
          path_a
        else
          "#{ @path_x }".split @node.path_separator  #  :+#gigo
        end
      end
    end
  end
end
