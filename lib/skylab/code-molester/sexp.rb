# this file must have no implied dependencies, i.e. is standalone
module Skylab
  module CodeMolester
    # thanks to zenspider
    class Sexp < Array
      # this name for this method is experimental.  the name may change.
      def detect *a, &b
        (b or 1 != a.size or ! a.first.kind_of?(Symbol)) and return super
        self[1..-1].detect { |n| n.kind_of?(Array) and n.first == a.first }
      end
      def to_s
        # although for now we are discouraging this structure, we allow for the possibility of pure-list nodes
        use_these = first.kind_of?(Symbol) ? self[1..-1] : self
        use_these.map do |node|
          case node
          when Sexp
            node.to_s
          when Array
            _use_these = node.first.kind_of?(Symbol) ? node[1..-1] : node
            _use_these.map(&:to_s).join('')
          else
            node.to_s
          end
        end.join('')
      end
    end
  end
end

