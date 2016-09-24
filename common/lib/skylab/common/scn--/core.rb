module Skylab::Common

  module Scn__  # read [#ba-022] the scanners narrative

    class << self

      def try_convert x  # :+[#056]

        if x.respond_to? :each_index
          Home_.lib_.basic::List.line_stream x

        elsif x.respond_to? :read
          Home_.lib_.system_lib::IO.line_stream x

        elsif x.respond_to? :each
          Home_.lib_.basic::Enumerator.line_stream x

        elsif x.respond_to? :ascii_only?
          Home_.lib_.basic::String.line_stream x

        else
          false
        end
      end
    end

    # basic list scanner aggregate
    # aggregates other scanners, makes them behave as one sequence of scanners
    #
    #     scn_via = Home_.lib_.basic::List.line_stream.method :new
    #
    #     scn = Home_::Scn.aggregate(
    #       scn_via[ [ :a, :b ] ],
    #       scn_via[ [] ],
    #       scn_via[ [ :c ] ],
    #     )
    #
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

      def initialize scn_a

        @gets_p = -> do
          if scn_a.length.nonzero?
            scn = scn_a[ 0 ] ; d = 0 ; last = scn_a.length - 1
            (( @gets_p = -> do
              while ! (( r = scn.gets ))
                if last == d
                  @gets_p = EMPTY_P_ ; break
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

      def count
        @count_p.call
      end

      def gets
        @gets_p.call
      end
    end

    class Delay

      def initialize p
        close = -> { @gets_p = EMPTY_P_ ; nil }
        @gets_p = -> do
          scn = p.call
          if ! scn then close[] else
            @gets_p = -> do
              r = scn.gets
              r or close[]
              r
            end
            @gets_p.call
          end
        end
      end

      def gets
        @gets_p.call
      end
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
