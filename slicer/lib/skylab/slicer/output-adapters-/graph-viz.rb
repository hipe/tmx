module Skylab::Slicer

  Output_Adapters_ = ::Module.new

  module Output_Adapters_::Graph_Viz

    class Labeller

      def initialize x
        @_down = x
      end

      def << s10n
        @_down.puts "  #{ s10n.sigil } [ label=\"#{ s10n.x.const }\" ]"
        self
      end
    end
  end
end
