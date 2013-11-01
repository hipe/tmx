module Skylab::Basic

  module List::Scanner

    def self.[] x
      if x.respond_to? :each_index
        List::Scanner::For::Array.new x
      elsif x.respond_to? :read
        List::Scanner::For::Read.new x
      else
        raise "#{ self } can't resolve a scanner for ::#{ x.class }"
      end
    end
  end

  module List::Scanner::For

    MAARS[ self ]

  end

  class List::Scanner::For::Array

    # in theory array can be mutated mid-scan.
    # it just maintains two indexes internally, one from the begnining
    # and one from the end, and checks current array length against these two
    # at every `gets` or `rgets`.

    # (leave this line intact, this is when we flipped it back - as soon as
    # the number of functions outnumbered the number of [i]vars it started
    # to feel silly. however we might one day go back and compare the one vs.
    # the other with [#bm-001])

    def initialize a
      @idx = @ridx = 0
      @a = a
    end
    def reset
      @idx = @ridx = 0
      nil
    end
    def eos?
      @idx >= ( @a.length - @ridx )
    end
    def gets
      fetchs if ! eos?
    end
    def ungets
      @idx < 0 and raise ::IndexError, "attempt to `ungets` past beginning"
      @idx -= 1
    end
    def fetchs
      r = @a.fetch @idx
      @idx += 1
      r
    end
    def fetch_chunk num
      0 <= num && num <= remaining_count or raise ::IndexError, "at least #{
        }#{ num } more element#{ 's' if 1 != num } #{
        }#{ 1 == num ? 'is' : 'are' } expected."
      r = ( num - 1 ).downto( 0 ).map do |i|
        @a.fetch( @idx + i )
      end
      @idx += num
      r.reverse
    end
    def rgets
      if ! eos?
        @ridx += 1
        @a.fetch( -1 * @ridx )
      end
    end
    def count
      @idx
    end
    def remaining_count
      @a.length - @ridx - @idx
    end
    def index
      @idx - 1 if @idx.nonzero?
    end
    def terminate
      @ridx = @idx = @a.length
      nil
    end
  end

  module List::Scanner

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

    class For::Enumerator
      def initialize enum
        @gets_p = -> do
          begin
            enum.next
          rescue ::StopIteration
            @gets_p = MetaHell::EMPTY_P_ ; nil
          end
        end
      end
      def gets ; @gets_p.call end
    end

    # basic list scanner
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
  end
end
