module Skylab
  module Dependency
    class Primordial
      def merge_in! *a, &b
        @defs ||= []
        if a.any?
          case a.size
          when 1; @defs.push [:file, a[0]]
          else raise ArgumentError.new("expecting one arg, had #{a.size}")
          end
        end
        b and b.call(self)
        self
      end
      def inflated?
        false
      end
      def inflate
        require File.expand_path('../graph', __FILE__)
        graph = nil
        @defs.each do |means, data|
          _graph =
          case means
          when :file
            Graph.from_file data
          else fail("implement me: #{means}")
          end
          if graph
            graph.merge_in!(_graph) # not implemented!
          else
            graph = _graph
          end
        end
        graph
      end
    end
  end
end
