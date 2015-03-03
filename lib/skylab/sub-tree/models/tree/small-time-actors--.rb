module Skylab::SubTree

  module Models::Tree

    Small_Time_Actors__ = ::Module.new

    class Small_Time_Actors__::Fetch_or_create

      Callback_::Actor.methodic self, :properties,

        :path,
        :node_payload,
        :init_node,
        :else_p,
        :node

    private

      def create_if_necessary=
        @OK_to_create = true
        KEEP_PARSING_
      end

      def do_not_create=
        @OK_to_create = false
        KEEP_PARSING_
      end

      def initialize & edit_p
        @node_payload = nil
        @else_p = nil
        @init_node = nil
        instance_exec( & edit_p )
      end

    public

      def execute

        path_a = __some_normalized_path_a

        node = if path_a.length.zero?
          @node
        else
          _touch_via_nonzero_length_path path_a, @node
        end

        if @node_payload
          node.set_node_payload @node_payload
        end

        node
      end

      def __some_normalized_path_a

        path_a = ::Array.try_convert @path
        if path_a
          path_a
        else
          __some_normd_path_a_when_not_array
        end
      end

      def __some_normd_path_a_when_not_array

        if @path
          "#{ @path }".split @node.path_separator
        else
          raise ::ArgumentError, "missing required property `path`"  # or use simple properties
        end
      end

      def _touch_via_nonzero_length_path mutable_path_a, node

        slug = mutable_path_a.shift

        if node.has_children
          child = node[ slug ]
        end

        if child
          if mutable_path_a.length.zero?
            child
          else
            _touch_via_nonzero_length_path mutable_path_a, child
          end

        elsif @else_p
          @else_p[]

        elsif @OK_to_create

          child = node.class.new :slug, slug, :name_services, node

          if @init_node
            @init_node[ child ]
          end

          if mutable_path_a.length.zero?  # again..
            child
          else
            _touch_via_nonzero_length_path mutable_path_a, child
          end
        end
      end
    end
  end
end
