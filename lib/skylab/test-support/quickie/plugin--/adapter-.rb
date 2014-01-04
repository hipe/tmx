module Skylab::TestSupport

  module Quickie

    class Plugin__::Adapter_

      def initialize const_i, kls, svc
        @const_i = const_i ; @kls = kls ; @svc = svc
        @client = kls.new self
      end

      #  ~ mechanics, reflection & services ~

      def plugin_i
        @plugin_i ||= Autoloader::FUN::Methodize[ @const_i ]
      end

      def intern  # #comport with the `client_x` articulation API of possible-
        plugin_i
      end

      attr_reader :client, :signature

      def syntax_moniker
        a = [ ] ; c = @client
        o = c.opts_moniker
        r = c.args_moniker
        if o
          r and o = "[#{ o }]"
          a << o
        end
        r and a << r
        a.length.zero? and a << plugin_i.to_s
        a * ' '
      end

      def some_desc_a
        a = [ ]
        @client.desc a
        a
      end

      def _svc  # #hacks-only
        @svc
      end

      #  ~ eventpoint-ish-es the plugin gets ~

      def prepare input_x
        sig = POSSIBLE_GRAPH_.new_graph_signature self, input_x.dup
        x = @client.prepare sig
        if x
          @signature = sig
        end
        x
      end

      def eventpoint_notify ep
        @client.send ep.eventpoint_notify_method_name
      end

      # ~

      SERVICES_THAT_PLUGINS_WANT__ = %i(
        get_test_path_a
        paystream
        plugins
        program_moniker
        y ).freeze

      SERVICES_THAT_PLUGINS_WANT__.each do |i|
        define_method i do
          @svc.send i
        end
      end

      def build_fuzzy_flag a
        @svc.build_fuzzy_flag a
      end
    end
  end
end
