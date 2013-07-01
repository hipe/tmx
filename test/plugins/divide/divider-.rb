module Skylab::Test

  class Plugins::Divide

    class Divider_

      def initialize err, subtree_provider, num, is_random
        @err, @num, @is_random = err, num, is_random
        @subtree_provider = subtree_provider
        nil
      end

      def divide
        if ! @num
          @err.puts "(defaulting to #{ default_num } subdivisions)"
          @num = default_num
        end
        big_a = get_big_a
        len = big_a.length
        if @num > len
          @err.puts "(integer is larger than (#{ len }). subdividing it to 1)"
          @num = 1
        end
        if @is_random
          big_a.shuffle!
        end
        partition big_a
      end

    private

      DEFAULT_NUM_ = 3
      def default_num ; DEFAULT_NUM_ end

      def get_big_a
        @subtree_provider.hot_subtree.children.reduce [] do |y, tree|
          if tree.children.count.nonzero?
            y << tree
          end
          y
        end
      end

      def partition big_a
        len = big_a.length ; num = @num
        small_int = len / num
        big_p = -> { big_a }
        div_a = num.times.map { Division_.new big_p, small_int }
        sum = div_a.reduce( 0 ) { |tot, div| tot += div.count }
        idx = 0
        while sum < len  # we rounded down, so now even it back up.
          div_a[ idx ].count += 1
          sum += 1 ; idx += 1
          if idx == num
            idx = 0
          end
        end
        div_a.first.start_index = ( idx = 0 )
        div_a[ 1 .. -1 ].each do |div|
          div.start_index = ( idx += div.count )
        end
        div_a
      end

      class Division_
        def initialize big_a_p, count
          @big_a_p = big_a_p
          @count = count
        end
        attr_accessor :count, :start_index

        def each &blk
          big_a = @big_a_p.call
          rang = ( @start_index ... ( @start_index + @count ) )
          ea = ::Enumerator.new do |y|
            rang.each do |i|
              y << big_a.fetch( i ).data
            end
            nil
          end
          blk ? ea.each( & blk ) : ea
        end

        def map &blk
          each.map( & blk )
        end
      end
    end
  end
end
