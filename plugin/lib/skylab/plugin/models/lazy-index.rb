module Skylab::Plugin

  class Models::LazyIndex < Common_::SimpleModel  # :[#007]

    # -

      def initialize
        @_plugins = []  # array of instances
        @_queue_of_offsets_of_plugins_with_execution_pending = []
        @_natural_key_via_offset = []  # the reverse of the below
        @_offset_via_natural_key = {}  # index into the array of instances
        super
      end

      attr_writer(
        :construct_plugin_by,
        :feature_branch,
      )

      def dereference_plugin_via_normal_symbol sym
        _ref_x = @feature_branch.dereference sym
        dereference_plugin_via_loadable_reference _ref_x
      end

      def dereference_plugin_via_loadable_reference ref_x  # #here
        ref_x.HELLO_LOADABLE_REFERENCE
        dereference_plugin offset_of_touched_plugin_via_user_value ref_x
      end

      def offset_of_touched_plugin_via_normal_symbol sym  # 1x [ts]
        _lt = @feature_branch.dereference sym
        offset_of_touched_plugin_via_user_value _lt
      end

      def offset_of_touched_plugin_via_user_value lt  # #here
        lt.HELLO_LOADABLE_REFERENCE
        key_x = @feature_branch.natural_key_of lt
        @_offset_via_natural_key.fetch key_x do
          plugin = __load_plugin lt  # if nil/false, it's OK we cache that too
          d = @_plugins.length
          @_plugins.push plugin
          @_natural_key_via_offset[ d ] = key_x
          @_offset_via_natural_key[ key_x ] = d
          d
        end
      end

      def __load_plugin ref

        ref.HELLO_LOADABLE_REFERENCE

        cls = ref.dereference_loadable_reference  # #here
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

      def natural_key_via_offset d
        @_natural_key_via_offset.fetch d
      end
    # -
  end
end
# :#here denotes areas where we're confused about whether to pass a.t's or l.t's
# #tombstone-A: full rewrite from "dependencies"
