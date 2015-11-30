module Skylab::Plugin

  class BaselessCollection

    Modality_Adapters_ = ::Module.new
    class Modality_Adapters_::CLI

      # this two-way adapter provides a consistent interface for both
      # the plugin dependency to its client and the client to the plugin.

      attr_writer(
        :cool_pool,
        :eventpoint_graph,
        :plugin_collection,
        :plugin_services,
        :plugin_tree_seed,
      )

      def new const
        dup.___init const
      end

      def ___init const

        @_const = const
        @_dependency = @plugin_tree_seed.const_get( const, false ).new self
        @_signature = nil
        self
      end

      def intern
        plugin_symbol
      end

      # -- for client of dependency

      # ~ initialization-esque

      def prepare input_x

        sig = @eventpoint_graph.new_graph_signature self, input_x.dup

        x = @_dependency.prepare sig
        if x
          @_signature = sig
        end
        x
      end

      def signature
        @_signature
      end

      # ~ eventing

      def eventpoint_notify ep
        @_dependency.send ep.eventpoint_notify_method_name
      end

      # ~ generic readers

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
        @___plugin_symbol ||= Callback_::Name::Conversion_Functions::Methodize[ @_const ]
      end

      def dependency_
        @_dependency
      end

      # -- for dependency of client (alphabetical)

      def add_iambic x_a
        @plugin_services.add_iambic x_a
      end

      def client_moniker
        @plugin_services.moniker_
      end

      def build_fuzzy_flag a
        @cool_pool.build_fuzzy_flag a
      end

      def build_required_arg_switch a
        @cool_pool.build_required_arg_switch a
      end

      def get_test_path_a
        @plugin_services.get_test_path_a
      end

      def infostream
        @plugin_services.infostream_
      end

      def paystream
        @plugin_services.paystream_
      end

      def plugins
        @plugin_collection
      end

      def program_moniker
        @plugin_services.program_moniker
      end

      def replace_test_path_s_a s_a
        @plugin_services.replace_test_path_s_a s_a
      end

      def some_desc_a
        a = []
        @_dependency.desc a
        a
      end

      def to_test_path_stream
        @plugin_services.to_test_path_stream
      end

      def y
        @plugin_services.y
      end
    end
  end
end
