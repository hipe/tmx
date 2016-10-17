module Skylab::Common

  class Stream::Ordered_via_DependencyTree

      # (we're
      # calling this the first known implementation of [#ta-005] pathfinding,
      # although technically that's a misnomer: this does not work against
      # general acyclic directed graphs but only (perhaps) trees, where every
      # node is allowed to point to at most one "parent" that it must go after.)

    class << self

      def prototype_by & p
        o = self.begin
        p[ o ]
        o.freeze
      end

      alias_method :begin, :new
      undef_method :new
    end  # >>

    def initialize
    end

    def execute_against item_stream
      otr = dup
      otr.upstream = item_stream
      otr.execute
    end

    attr_writer(
      :method_name_for_identifying_key,  # `name_value_for_order`
      :method_name_for_reference_key,  # `after_name_value_for_order`
      :upstream,
    )

    def execute

      @_ready_buffer_queue = []
      @_state = :_main
      @_went_h = {}
      @_waiting_h = {}

      Home_.stream do
        send @_state
      end
    end

    def __gets_from_buffer
      begin
        item = @_ready_buffer_queue.first.gets
        if item
          _see_item item, item.send( @method_name_for_identifying_key )
          break
        end
        @_ready_buffer_queue[ 0, 1 ] = EMPTY_A_
        if @_ready_buffer_queue.length.zero?
          @_state = :_main
          item = _main
          break
        end
        redo
      end while above
      item
    end

    def _main

      begin
        item = @upstream.gets

        if ! item
          @_state = :_done
          if @_waiting_h.length.nonzero?
            x = __when_unresolved
          end
          break
        end

        my_name_x = item.send @method_name_for_identifying_key

        i_go_after_this_x = item.send @method_name_for_reference_key

        _i_may_go_now = if i_go_after_this_x
          @_went_h.key? i_go_after_this_x
        else
          true
        end

        if _i_may_go_now
          _see_item item, my_name_x
          x = item
          break
        end

        __add_item_to_wait_buffer item, i_go_after_this_x

        redo
      end while above
      x
    end

    def __add_item_to_wait_buffer item, name_x
      h = @_waiting_h
      a = h.fetch name_x do
        h[ name_x ] = []
      end
      a.push item
      NIL
    end

    def _see_item item, my_name_x
      @_went_h[ my_name_x ] = true
      items_waiting_for_me = @_waiting_h.delete my_name_x
      if items_waiting_for_me
        @_ready_buffer_queue.push Home_::Stream.via_nonsparse_array items_waiting_for_me
        @_state = :__gets_from_buffer
      end
      NIL
    end

    def __when_unresolved

        _line_a = @waiting_h.each_pair.map do | i, a |
          _i_a = a.map do | item |
            item.send @method_name_for_identifying_key
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
