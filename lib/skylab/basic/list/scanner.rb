module Skylab::Basic

  class List::Scanner < ::Proc  # read [#022] the scanners narrative

    # basic list scanner
    # like this:
    #
    #     a = %i( only_one )
    #     scn = Basic::List::Scanner.new do a.shift end
    #     scn.gets  # => :only_one
    #     scn.gets  # => nil

    alias_method :gets, :call

    def self.[] x
      if x.respond_to? :each_index
        List::Scanner::For::Array.new x
      elsif x.respond_to? :read
        List::Scanner::For::Read.new x
      elsif x.respond_to? :each
        List::Scanner::For::Enumerator.new x
      elsif x.respond_to? :ascii_only?
        List::Scanner::For::String[ x ]
      else
        raise "#{ self } can't resolve a scanner for ::#{ x.class }"
      end
    end

    module IM__
      def to_a
        to_enum( :fat_each ).to_a
      end
    private
      def fat_each
        while (( x = gets )) ; yield x.collapse end
        nil
      end
    end

    # basic list scanner aggregate
    # aggregates other scanners, makes them behave as one sequence of scanners
    #
    #     scn = Basic::List::Scanner::Aggregate[
    #         Basic::List::Scanner[ [ :a, :b ] ],
    #         Basic::List::Scanner[ [ ] ],
    #         Basic::List::Scanner[ [ :c ] ] ]
    #     scn.count  # => 0
    #     scn.gets  # => :a
    #     scn.count  # => 1
    #     scn.gets  # => :b
    #     scn.count  # => 2
    #     scn.gets  # => :c
    #     scn.count  # => 3
    #     scn.gets  # => nil
    #     scn.count  # => 3

    class Aggregate
      class << self ; alias_method :[], :new end
      include IM__
      def initialize * scn_a
        @gets_p = -> do
          if scn_a.length.nonzero?
            scn = scn_a[ 0 ] ; d = 0 ; last = scn_a.length - 1
            (( @gets_p = -> do
              while ! (( r = scn.gets ))
                if last == d
                  @gets_p = MetaHell::EMPTY_P_ ; break
                else
                  scn = scn_a[ d += 1 ]
                end
              end
              r
            end )).call
          end
        end
        @count_p = -> do
          scn_a.reduce( 0 ) do |m, scn|
            m + (( scn.count or fail "count from #{ scn.class }?" ))
          end
        end
      end
      def count ; @count_p.call end ; def gets ; @gets_p.call end
    end

    def self.Delay &p
      Delay.new p
    end

    class Delay
      def initialize p
        close = -> { @gets_p = MetaHell::EMPTY_P_ ; nil }
        @gets_p = -> do
          scn = p.call
          if ! scn then close[] else
            (( @gets_p = -> do
              r = scn.gets
              r or close[]
              r
            end )).call
          end
        end
      end
      def gets ; @gets_p.call end
    end

    class Map_Reduce
      def initialize * x_a
        st = St__.new ; st[ x_a.shift ] = x_a.shift while x_a.length.nonzero?
        @gets_p_p, @map_pass_filter_p = st.to_a ; @count = 0
        normal_p = -> do
          while (( r = @gets_p.call ))
            if (( r_ = @map_pass_filter_p[ r ] ))
              break( @count += 1 )
            end
          end
          r_
        end
        @p = -> do
          @gets_p = @gets_p_p.call
          (( @p = normal_p )).call
        end
        nil
      end
      St__ = ::Struct.new :gets_p_p,  :map_pass_filter_p
      attr_reader :count
      def gets
        @p.call
      end
    end

    class Map_Expand
      def initialize scn, expand_p
        @count = 0 ; @expand_p = expand_p ; @expanse = @expanse_fly = nil
        @hot = true ; @scn = scn ; nil
      end
      attr_reader :count
      def gets
        while @hot
          if @expanse
            r = @expanse.gets
            r and break( @count += 1 )
            @expanse_fly = @expanse ; @expanse = nil
          end
          x = @scn.gets
          x or break( @hot = false )
          build_expanse x
        end
        r
      end
    private
      def build_expanse x
        if @expanse_fly
          @expanse_fly.clear_expanse
          @expanse = @expanse_fly ; @expanse_fly = nil
        else
          @expanse = Expanse__.new
        end
        @expanse.instance_exec x, & @expand_p
        nil
      end
      class Expanse__
        def initialize
          @p_a = [ ]
        end
        def clear_expanse
          @p_a.clear ; nil
        end
        def gets
          while @p_a.length.nonzero?
            p = @p_a.shift
            x = p.call
            x and break( r = x )
          end
          r
        end
      private
        def push_callable p
          @p_a << p ; nil
        end
      end
    end

    module With

      def self.[] scn, * i_a
        _mod = scn.respond_to?( :superclass ) ? scn : scn.singleton_class
        With.apply_iambic_on_client i_a, _mod ; nil
      end
      MetaHell::Bundle::Directory[ self ]
    end

    LINE_RX_ = /[^\r\n]*\r?\n|[^\r\n]+\r?\n?/

  end
end
