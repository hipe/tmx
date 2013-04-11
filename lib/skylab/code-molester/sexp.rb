module ::Skylab::CodeMolester

  # apologies to zenspider

  class Sexp < ::Array

    # this name for this method is experimental.  the name may change.

    def detect *a, &b
      (b or 1 != a.size or !(::Symbol === a.first)) and return super
      self[1..-1].detect { |n| ::Array === n and n.first == a.first }
    end

    def last *a
      0 == a.size and return super
      ii = (size-1).downto(1).detect { |i| ::Array === self[i] and self[i].first == a.first }
      self[ii] if ii
    end

    # `each` - experimental new wrapper around experimental new sexp scanner

    def each *a, &b
      if 1 == a.length
        ea = ::Enumerator.new do |y|
          with_scanner_for_symbol a.fetch( 0 ) do |scn|
            while x = scn.gets
              y << x
            end
            nil
          end
        end
        b ? ea.each( &b ) : ea
      else
        super
      end
    end

    def with_scanner &blk
      Sexp::Scanner.with_scanner self, &blk
    end

    def with_scanner_for_symbol sym, &blk
      Sexp::Scanner::Bound.with_symbol_scanner self, sym, &blk
    end

    def remove sexp
      size <= 1 and return fail "cannot remove anything from empty sexp!"
      oid = sexp.object_id
      index = (1..(size-1)).detect { |idx| oid == self[idx].object_id }
      index or return fail "sexp with oid #{oid} was not an immediate child of this sexp."
      self[index, 1] = [] # ruby is amazing
      sexp
    end

    def select *a, &b
      (b or 1 != a.size or !(::Symbol === a.first)) and return super
      self[1..-1].select { |n| ::Array === n and n.first == a.first }
    end

    def symbol_name
      ::Symbol === first ? first : false
    end

    def unparse sio=nil
      out = sio || CodeMolester::Services::StringIO.new
      self[1..-1].each do |child|
        if child.respond_to? :unparse
          child.unparse out
        else
          out.write child.to_s
        end
      end
      out.string unless sio
    end
  end

  class << Sexp

                                  # builds the sexp either with the registered
    def [] *a                     # factory or as a generic sexp based on if
      k = if factory_ivar and a.length.nonzero?  # a factory with that name was
        @factory[a.first]         # registered. uses self as a default here
      else                        # (see below)
        self
      end
      k.new.concat a
    end

    def []= symbol_name, sexp_klass            # register a factory
      factory[symbol_name] = sexp_klass
    end

    attr_reader :factory ; alias_method :factory_ivar, :factory

    def factory
      @factory ||= ::Hash.new self
    end
  end

  # NOTE this assumed "strict sexps" [#003]

  class Sexp::Scanner

    module ModuleMethods
      def pool!
        class << self
          protected :new
        end
        pool_a = [ ]
        define_singleton_method :with_instance do |&b|
          o = pool_a.length.nonzero? ? pool_a.pop : new
          r = b[ o ]
          o.clear
          pool_a << o
          r
        end
      end
    end
    extend ModuleMethods

    pool!

    def self.with_scanner sexp, &blk
      with_instance do |scn|
        scn.set_sexp sexp
        blk[ scn ]
      end
    end

    # ( for internal fly-weighting use only )
    def set_sexp sexp
      srch_sym = nil
      gets = FUN.build_gets[ sexp, -> x do
        x.respond_to? :each_index and srch_sym = x.fetch( 0 )
      end ]
      @scan = -> search_symbol do
        srch_sym = search_symbol
        gets[ ]
      end
    end

    FUN = -> do
      o = { }
      o[:build_gets] = -> sexp, match do
        last = sexp.length - 1
        hot = 0 < last  # sexps of length 0 or 1 don't get walked at all! [#003]
        pos = 0  # note the first visited nerk will be 1
        -> do
          res = nil
          while hot
            pos += 1
            x = sexp.fetch pos
            break( res = x ) if match[ x ]
            hot = false if last == pos
          end
          res
        end
      end
      ::Struct.new( * o.keys ).new( * o.values )
    end.call

    def scan search_symbol
      @scan[ search_symbol ]
    end

    def clear
      @scan = nil
    end
  end

  class Sexp::Scanner::Bound  # Bound to a search method

    extend Sexp::Scanner::ModuleMethods

    pool!

    def self.with_symbol_scanner sexp, search_symbol, &blk
      with_instance do |scn|
        scn.set_as_symbol_scanner sexp, search_symbol
        blk[ scn ]
      end
    end

    # internal use (as flyweight) only!
    def set_as_symbol_scanner sexp, search_symbol
      @gets = Sexp::Scanner::FUN.build_gets[ sexp, -> x do
        x.respond_to? :each_index and search_symbol == x.fetch( 0 )
      end ]
      nil
    end

    def gets
      @gets.call
    end

    def clear
      @gets = nil
    end
  end
end
