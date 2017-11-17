module Skylab::Treemap

  class Output_Adapters_::Inspect

    def initialize o, & p
      @_listener = p
      @_serr = o.stderr_
    end

    def required_stream
      :leaf_stream
    end

    attr_writer :leaf_stream

    def execute

      o_st = @leaf_stream
      @_seen_h = {}

      begin
        o = o_st.gets
        o or break
        __express o
        redo
      end while nil

      ACHIEVED_
    end

    def maybe_receive_event_on_channel i_a, & ev_p

      if :info == i_a.first && :data == i_a[ 1 ]
        send :"__receive__#{ i_a.last }__", ev_p[]
      else
        @_listener.call( * i_a, & ev_p )
      end
    end

    def __receive__branch_cache_array__ o

      @_branch_cache = o
      NIL_
    end

    def __express o

      st = o.to_parent_stream_around @_branch_cache

      st.each do | o_ |
        @_seen_h.fetch o_.branch_number do | d |
          @_seen_h[ d ] = true
          @_serr.puts o_.description_for_branch
        end
      end

      @_serr.puts o.description_for_leaf_under_etc @_branch_cache

      NIL_
    end
  end
end
