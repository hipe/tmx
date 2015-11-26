module Skylab::Basic

  Time = ::Module.new
  Time::EN = ::Module.new

  #                      ~ this is only a sketch ~                       #

  Time::EN::Summarize = -> do  # apologies to "chronic"

    a = [[ :second, 1.0 ]]
    a << [ :minute, 60 * a.last.last ]
    a << [ :hour, 60 * a.last.last ]
    a << [ :day, 24 * a.last.last ]
    a << [ :week, 7 * a.last.last ]
    a << [ :month, 4 * a.last.last ]
    a << [ :year, 365.25 * a[3].last ] # ick sorry
    a.reverse!

    -> delta_seconds do
      delta_seconds = delta_seconds.abs
      res = nil
      if delta_seconds > a.first.last          # delta is bigger than the
        res = [ a.first.first, delta_seconds / a.first.last ]  # biggest unit
      else
        o = a.detect { |x| x.last < delta_seconds }
        if o
          res = [ o.first, delta_seconds / o.last ]
        else
          res = [ :second, delta_seconds ]     # delta is smaller than the
        end                                                  # smallest unit
      end
      res
    end
  end.call
end
