module Skylab::Brazen

  class Entity::Meta_Meta_Meta_Properties::Arity < ::Module

    # (the spec provides comprehensive documentation and 100% coverage)

    class Space < ::Module

      def self.create default_proc=nil, & p
        mod = new default_proc
        mod.module_exec( & p )
        mod
      end

      def initialize default_proc
        @default_proc = ( default_proc and wrap_dflt_proc default_proc )
        @indexed = false
      end

    private

      def wrap_dflt_proc p
        -> k do
          p[ self, k ]
        end
      end

    public

      def new lo, hi
        Arity_.new lo, hi
      end

      def each
        if block_given?
          scn = get_stream ; arty = nil
          yield arty while (( arty = scn.gets ))
        else
          to_enum
        end
      end

      def get_stream
        box.get_value_stream
      end

      def members
        box.to_value_stream.map do | arity |
          arity.name_symbol
        end
      end

      def [] nn
        box[ nn ]
      end

      def fetch nn, &p
        box.fetch nn, & ( p || @default_proc )
      end

    private

      def box
        @indexed or index
        @box
      end

      def index
        bx = Common_::Box.new
        constants.each do |c|
          ar = const_get c, false
          bx.add ar.name_symbol, ar
        end
        @indexed = true
        @box = bx
        freeze
        nil
      end
    end

    def initialize lo, hi
      @begin = lo ; @end = hi
      @includes_zero = lo.zero?
      @is_polyadic = hi.nil?
      @is_zero = lo.zero? && ( hi && hi.zero? )
      @is_one = @is_zero ? false : ( 1 == lo && 1 == hi )
      nil
    end

    attr_reader :begin, :end, :includes_zero, :is_polyadic, :is_zero, :is_one

    def local_name_function
      @lnf ||= bld_lnf
    end
  private
    def bld_lnf
      Common_::Name.via_variegated_symbol name_symbol
    end
  public

    def name_symbol
      @name_symbol ||= bld_lnn
    end
  private
    def bld_lnn
      n = name
      n[ n.rindex( CONST_SEP_ ) + 2 .. -1 ].downcase.intern
    end
  public

    def include? d
      @begin <= d and @end.nil? || @end >= d
    end

    Arity_ = self
  end
end
