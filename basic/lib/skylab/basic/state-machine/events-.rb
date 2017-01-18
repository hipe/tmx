module Skylab::Basic

  class StateMachine

    Events_ = ::Module.new

    cls = Common_::Event.prototype_with(

      :no_available_state_transition,
      :x, nil,
      :had_more, nil,
      :possible_state_array, nil,
      :error_category, :argument_error,
      :ok, false,

    ) do |y, o|

      s_a = []
      o.possible_state_array.each do | sta |
        s_a.push sta.description_under self
      end

      _context = if o.had_more
        " at #{ ick o.x }"
      else
        " at end of input"
      end

      _expecting = if s_a.length.zero?
        "no more input"
      else
        or_ s_a
      end

      y << "expecting #{ _expecting }#{ _context }"
    end

    def cls.via upstream, sta_st

      if upstream.no_unparsed_exists
        had_more = false
      else
        had_more = true
        x = upstream.head_as_is
      end

      _sta_a = sta_st.to_a

      new_with(
        :x, x,
        :had_more, had_more,
        :possible_state_array, _sta_a,
      )
    end

    Events_::NoAvailableStateTransition = cls

    # ==
  end
end
