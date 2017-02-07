module Skylab::Plugin

  class Models::LazyIndex < Common_::SimpleModel  # :[#007]

    # -

      def initialize
        @_plugins = []  # array of instances
        @_queue_of_offsets_of_plugins_with_execution_pending = []
        @_offset_via_natural_key = {}  # index into the array of instances
        super
      end

      attr_writer(
        :construct_plugin_by,
        :operator_branch,
      )

      def dereference_plugin_via_normal_symbol sym
        _lt = @operator_branch.dereference sym
        dereference_plugin_via_user_value _lt
      end

      def dereference_plugin_via_user_value lt  # #here
        lt.HELLO_LOAD_TICKET
        dereference_plugin offset_of_touched_plugin_via_user_value lt
      end

      def offset_of_touched_plugin_via_user_value lt  # #here
        lt.HELLO_LOAD_TICKET
        key_x = @operator_branch.natural_key_of lt
        @_offset_via_natural_key.fetch key_x do
          plugin = __load_plugin lt  # if nil/false, it's OK we cache that too
          d = @_plugins.length
          @_plugins.push plugin
          @_offset_via_natural_key[ key_x ] = d
          d
        end
      end

      def __load_plugin lt

        lt.HELLO_LOAD_TICKET

        cls = @operator_branch.dereference_user_value lt  # #here
        # ..
        @construct_plugin_by[ cls ]
      end

      def dereference_plugin offset
        @_plugins.fetch offset
      end

      def enqueue offset
        @_queue_of_offsets_of_plugins_with_execution_pending.push offset ; nil
      end

      def to_scanner_of_offsets_of_plugins_with_pending_execution
        # `via_times` not in scanner but [#co-060.2] will hit if it does
        d = -1
        last = @_queue_of_offsets_of_plugins_with_execution_pending.length - 1
        Zerk_no_deps_[]::Scanner_by.new do
          if last != d
            d += 1
            @_queue_of_offsets_of_plugins_with_execution_pending.fetch d
          end
        end
      end
    # -
  end
end
# :#here denotes areas where we're confused about whether to pass a.t's or l.t's
# #tombstone-A: full rewrite from "dependencies"
