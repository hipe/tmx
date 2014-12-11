module Skylab::Brazen

  class CLI

    class Actors__::Via_after_produce_ordered_scanner

      Actor_[ self, :properties, :upstream ]

      def initialize
        @went_h = {}
        @waiting_h = {}
        @ready_buffer_queue = []
        @gets_from_buffer = method :gets_from_buffer
        @main_loop = method :main_loop
        super
      end

      def execute
        @p = @main_loop
        Callback_::Scan.new do
          @p[]
        end
      end

      def main_loop
        begin
          item = @upstream.gets
          if ! item
            @p = EMPTY_P_
            if @waiting_h.length.nonzero?
              x = when_unresolved
            end
            break
          end

          my_name_sym = item.name.as_lowercase_with_underscores_symbol

          i_go_after_this_sym = item.action.class.after_i

          _i_may_go_now = if i_go_after_this_sym
            @went_h.key? i_go_after_this_sym
          else
            true
          end

          if _i_may_go_now
            see_item item, my_name_sym
            x = item
            break
          end

          add_item_to_wait_buffer item, i_go_after_this_sym

          redo
        end while nil
        x
      end

      def add_item_to_wait_buffer item, sym
        h = @waiting_h
        a = h.fetch sym do
          h[ sym ] = []
        end
        a.push item
        nil
      end

      def gets_from_buffer
        begin
          item = @ready_buffer_queue.first.gets
          if item
            see_item item, item.name.as_lowercase_with_underscores_symbol
            break
          end
          @ready_buffer_queue[ 0, 1 ] = EMPTY_A_
          if @ready_buffer_queue.length.nonzero?
            redo
          end
          @p = @main_loop
          item = @p[]
        end while nil
        item
      end

      def see_item item, my_name_sym
        @went_h[ my_name_sym ] = true
        items_waiting_for_me = @waiting_h.delete my_name_sym
        if items_waiting_for_me
          @ready_buffer_queue.push Callback_.stream.via_nonsparse_array items_waiting_for_me
          @p = @gets_from_buffer
        end
        nil
      end

      def when_unresolved

        _line_a = @waiting_h.each_pair.map do | i, a |
          _i_a = a.map do | item |
            item.name.as_lowercase_with_underscores_symbol
          end
          "#{ i } <- ( #{ _i_a * ', ' } )"
        end

        _seen_s = "( #{ @went_h.keys * ', ' } )"

        _msg = "unresolved `after` dependences: seen #{ _seen_s }, #{
          } still waiting: #{ _line_a * ', ' }"

        raise _msg
      end
    end
  end
end
