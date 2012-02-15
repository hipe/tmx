# this file must have no implied dependencies, i.e. is standalone
require 'stringio'

module Skylab
  module CodeMolester
    # thanks to zenspider
    class Sexp < Array
      class RuntimeError < ::RuntimeError; end
      # this name for this method is experimental.  the name may change.
      def detect *a, &b
        (b or 1 != a.size or !(Symbol === a.first)) and return super
        self[1..-1].detect { |n| Array === n and n.first == a.first }
      end
      def select *a, &b
        (b or 1 != a.size or !(Symbol === a.first)) and return super
        self[1..-1].select { |n| Array === n and n.first == a.first }
      end
      def to_s
        # although for now we are discouraging this structure, we allow for the possibility of pure-list nodes
        use_these = (Symbol === first)? self[1..-1] : self
        use_these.map do |node|
          case node
          when Sexp
            node.to_s
          when Array
            _use_these = (Symbol === node.first) ? node[1..-1] : node
            _use_these.map(&:to_s).join('')
          else
            node.to_s
          end
        end.join('')
      end
      def _sexp_fail msg
        raise RuntimeError.new(msg)
      end
      def symbol_name
        Symbol === first ? first : false
      end
      def unparse sio=nil
        unless sio
          sio = StringIO.new
          ret = true
        end
        self[1..-1].each do |child|
          if child.respond_to?(:unparse)
            child.unparse(sio)
          else
            sio.write child.to_s
          end
        end
        if ret
          sio.rewind
          sio.read
        end
      end
    end
    class << Sexp
      def [] *a
        new.concat([*a])
      end
    end
  end
end

