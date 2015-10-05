module Skylab::Snag

  class Models_::To_Do

    Events_ = ::Module.new

    Events_::No_Matches = Callback_::Event.prototype_with( :no_matches,

      :command, nil,
      :patterns, nil,
      :number_of_matches, nil,
      :ok, nil

    ) do | y, o |

      # :+[#016] this is a hand-tailored "surface case" of the idea of
      # of expressing only the part that failed, which is itself an
      # example of influence of [#hu-031] the optimal concision vector..
      #
      # ..which made more sense when we thought we could access a count of
      # the number of files. we can't because we pipe `find` to `grep`
      # directly in the system. which is fine. we found another tangent
      # to go on.

      parts = []
      parts << sp_(
        :subject, o.number_of_matches,
        :subject, 'found todo',
        :negative,
        :verb, 'have',
        :object, 'message content after it',
        :more_is_expected  # not sure
      )

      parts.push "in files"

      _np = o.command.express_under :EN
      _np.express_string_into_under parts, self

      y << ( parts * SPACE_ )
    end
  end

  # (when we did this differently)
  # ..it would likely be hard but not impossible to proceduralize the above
  # expression branches into the different templates (we want to get away
  # from thinking of anything as "templates", btw). a vector seems to be:
  # from most significant compositional "thing" to least, find the first
  # thing that had a count of zero. (tautologically, something did.) we
  # will express this zero-ness with this unit and any *relevant* detail.
  # if that compositional unit has a previous one (the unit of the next
  # greater significance), express the (always nonzero) count of that unit
  # too, in the same expression.

end
