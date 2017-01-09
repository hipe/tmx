module Skylab::Basic

  class StateMachine

    Events_ = ::Module.new

    Events_::No_Available_State_Transition = Common_::Event.prototype_with(

      :no_available_state_transition,
      :x, nil,
      :had_more, nil,
      :possible_state_array, nil,
      :error_category, :argument_error,
      :ok, false,

    ) do | y, o |

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
  end
end
