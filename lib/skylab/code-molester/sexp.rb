# this file must have no implied dependencies, i.e. is standalone
require 'stringio'

module Skylab
  module CodeMolester
    # thanks to zenspider
    class Sexp < Array
      # this name for this method is experimental.  the name may change.
      def detect *a, &b
        (b or 1 != a.size or !(Symbol === a.first)) and return super
        self[1..-1].detect { |n| Array === n and n.first == a.first }
      end
      def select *a, &b
        (b or 1 != a.size or !(Symbol === a.first)) and return super
        self[1..-1].select { |n| Array === n and n.first == a.first }
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
        ((@factory and a.any?) ? factory[a.first] : self).new.concat([*a])
      end
      def []= symbol_name, sexp_klass
        factory[symbol_name] = sexp_klass
      end
      def factory
        @factory ||= Hash.new(self)
      end
    end
  end
end

