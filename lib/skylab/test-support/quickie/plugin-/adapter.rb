module Skylab::TestSupport

  module Quickie

    Plugin_ = ::Module.new

    class Plugin_::Adapter

      # this two-way adapter provides a consistent interface for both
      # the plugin dependency to its client and the client to the plugin.

      def initialize cool_pool, col, client, box_mod

        @_box_mod = box_mod
        @_collection = col
        @_client = client
        @_cool_pool = cool_pool
      end

      def new const
        otr = dup
        otr.__init const
        otr
      end

      def __init const

        @_const = const
        @_dependency = @_box_mod.const_get( const, false ).new self
        @_signature = nil
        NIL_
      end

      # ~ comport with [#028]

      def intern
        plugin_symbol
      end

      # ~ for client to query / mutate state of dependency

      def eventpoint_notify ep
        @_dependency.send ep.eventpoint_notify_method_name
      end

      def signature
        @_signature
      end

      def prepare input_x

        sig = Here_::Sessions_::Front::POSSIBLE_GRAPH.
          new_graph_signature self, input_x.dup

        x = @_dependency.prepare sig
        if x
          @_signature = sig
        end
        x
      end

      def dependency_
        @_dependency
      end

      def syntax_moniker

        a = []
        dep = @_dependency
        om = dep.opts_moniker
        am = dep.args_moniker
        if om
          if am
            om = "[#{ om }]"
          end
          a.push om
        end
        if am
          a.push am
        end
        if a.length.zero?
          a.push plugin_symbol.id2name
        end
        a * SPACE_
      end

      def plugin_symbol
        @___plugin_symbol ||= LIB_.name_from_const_to_method @_const
      end

      # ~ for the dependency (alphab.)

      def add_iambic x_a
        @_client.add_iambic x_a
      end

      def client_moniker
        @_client.moniker_
      end

      def build_fuzzy_flag a
        @_cool_pool.build_fuzzy_flag a
      end

      def build_required_arg_switch a
        @_cool_pool.build_required_arg_switch a
      end

      def get_test_path_a
        @_client.get_test_path_a
      end

      def infostream
        @_client.infostream_
      end

      def paystream
        @_client.paystream_
      end

      def plugins
        @_collection
      end

      def program_moniker
        @_client.program_moniker
      end

      def replace_test_path_s_a s_a
        @_client.replace_test_path_s_a s_a
      end

      def some_desc_a
        a = []
        @_dependency.desc a
        a
      end

      def y
        @_client.y
      end
    end
  end
end
