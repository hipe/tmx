module Hipe::CssConvert
  class Sexpie < Array # appologies to zenspider, s-expression (Sexp) *like*
    class << self
      def [] (*a)
        if sexp = build(a) then sexp else a end
      end
      def build args
        if args.kind_of?(Array) and args.size == 2 &&
          args.first.kind_of?(Symbol) && args[1].kind_of?(Hash)
          new(args.first, args[1])
        end
      end
    end
    def initialize node_type_sym, attrs_hash
      super([node_type_sym, attrs_hash])
    end
    alias_method :orig_fetch, :[]
    def [] mixed
      mixed.kind_of?(Symbol) ? orig_fetch(1)[mixed] : super(mixed)
    end
    def node_type
      first
    end
    def children *ks
      if ks.empty?
        orig_fetch(1)
      else
        cx = children
        ks.map{ |k| cx[k] }
      end
    end
  end
end
