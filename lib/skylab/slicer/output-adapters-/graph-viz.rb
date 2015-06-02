module Skylab::Slicer

  Output_Adapters_ = ::Module.new
  module Output_Adapters_::Graph_Viz
    class Labeller
      def initialize x
        @_down = x
      end

      def << ss
        @_down.puts "  #{ ss.medo } [ label=\"#{ ss.const }\" ]"
        self
      end
    end
  end
end
