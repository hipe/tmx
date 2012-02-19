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
      def last *a
        0 == a.size and return super
        ii = (size-1).downto(1).detect { |i| Array === self[i] and self[i].first == a.first }
        self[ii] if ii
      end
      def remove sexp
        size <= 1 and return fail("cannot remove anything from empty sexp!")
        oid = sexp.object_id
        index = (1..(size-1)).detect { |idx| oid == self[idx].object_id }
        index or return fail("sexp with oid #{oid} was not an immediate child of this sexp.")
        self[index, 1] = [] # ruby is amazing
        sexp
      end
      def select *a, &b
        (b or 1 != a.size or !(Symbol === a.first)) and return super
        self[1..-1].select { |n| Array === n and n.first == a.first }
      end
      def symbol_name
        Symbol === first ? first : false
      end
      def unparse sio=nil
        out = sio || StringIO.new
        self[1..-1].each do |child|
          if child.respond_to?(:unparse)
            child.unparse(out)
          else
            out.write child.to_s
          end
        end
        out.string unless sio
      end
    end
    class << Sexp
      def [] *a
        (((@factory ||= nil) and a.any?) ? factory[a.first] : self).new.concat([*a])
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

