module Skylab::Headless

  class Arity < ::Module

    # (the spec provides comprehensive documentation and 100% coverage)

    class Space < ::Module

      def self.create &blk
        mod = new
        mod.module_exec( & blk )
        mod
      end

      def initialize
        @indexed = false
      end

      def new lo, hi
        Arity.new lo, hi
      end

      def members
        box.map( & :local_normal_name )
      end

      def [] nn
        box[ nn ]
      end

      def fetch nn, &b
        box.fetch nn, &b
      end

    private

      def box
        @indexed or index
        @box
      end

      def index
        bx = Headless::Services::Basic::Box.new
        constants.each do |c|
          ar = const_get c, false
          bx.add ar.local_normal_name, ar
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

    attr_reader :begin, :end, :includes_zero, :is_polyadic, :is_zero,  :is_one

    def local_normal_name
      @local_normal_name ||= begin
        n = name
        n[ n.rindex( '::' ) + 2 .. -1 ].downcase.intern
      end
    end

    def include? d
      @begin <= d and @end.nil? || @end >= d
    end
  end
end
