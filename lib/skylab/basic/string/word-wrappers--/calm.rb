module Skylab::Basic

  module String

    class Word_Wrappers__::Calm

      class << self
        alias_method :curry, :new
      end

      def initialize ind_s, d, y
        @a = [] ; @d = d
        base = Flush_Line__.curry do |fl|
          fl.indent_string = ind_s
          fl.max_width = d
          fl.word_buffer = @a
          fl.yielder = y
        end
        @flush_any_full_line = base.curry do |fl|
          fl.flush_method_i = :flush_any_full_line
        end
        @flush_some_one_line = base.curry do |fl|
          fl.flush_method_i = :flush_some_one_line
        end
        @trigger_width = d - 1
        @w = 0
        @y = y
      end
      def << s
        if s.length.zero?
          when_the_empty_string_is_added
        else
          add_nonzero_length_string s
        end
        self
      end
      def flush
        @flush_some_one_line[] while @a.length.nonzero?
        recalc_current_width ; nil
      end
    private
      def when_the_empty_string_is_added
        flush ; @y << EMPTY_S_ ; nil
      end
      def add_nonzero_length_string s
        @a.concat s.split SPACE_
        @w.zero? or @w += 1
        @w += s.length
        @trigger_width <= @w and overflow_flush ; nil
      end
      def overflow_flush
        @flush_some_one_line[]
        nil while @flush_any_full_line[]
        recalc_current_width ; nil
      end
      def recalc_current_width
        @w = @a.reduce( 0 ) { |m, x| m + x.length  }
        1 < @a.length and @w += @a.length - 1 ; nil
      end

      class Flush_Line__
        def self.curry
          yield (( fl = new )) ; fl
        end
        def curry
          yield (( fl = dup )) ; fl
        end
        def flush_method_i= i
          @i = i
        end
        def indent_string= s
          @s = s
        end
        def max_width= d
          @trigger_width = d - 1
          @d = d
        end
        def word_buffer= a
          @a = a
        end
        def yielder= y
          @y = y
        end
        def []
          send @i
        end
      private
        def flush_some_one_line
          @a.length.zero? and fail
          flsh_some_one_one
        end
        def flush_any_full_line
          @a.length.nonzero? and flsh_any_full_line
        end
        def flsh_some_one_one
          idx = calculate_stop_index
          idx ||= @a.length - 1
          flsh_with_non_negative_stop_index idx
        end
        def flsh_any_full_line
          idx = calculate_stop_index
          idx and flsh_with_non_negative_stop_index idx
        end
        def flsh_with_non_negative_stop_index idx
          output_s = "#{ @s }#{ @a[ 0 .. idx ] * SPACE_ }"
          @a[ 0 .. idx ] = []
          @y << output_s ; true
        end
        def calculate_stop_index  # assume nonzero length 'a'
          idx = 0 ; last = @a.length - 1 ; w = @a.fetch( idx ).length
          while true
            if @trigger_width <= w
              stop = @d == w ? idx : idx - 1
              -1 == stop and stop = 0  # first word is longer than limit
              break
            end
            last == idx and break
            w += 1 + @a.fetch( idx += 1 ).length
          end
          stop
        end
      end
    end
  end
end
