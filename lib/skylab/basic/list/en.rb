module Skylab::Basic

  module List::EN

    _Say_not_found = -> d, a, k do  # expose whenever

      s = Basic.lib_.human::Levenshtein.with(
        :item, k,
        :items, a,
        :closest_N_items, d,
        :aggregation_proc, -> a_ { a_ * ' or ' } )

      if s
        _did_you_mean = " - did you mean #{ _s }?"
      end

      "not found #{ MetaHell_.lib_.strange k }#{ _did_you_mean }"
    end

    _A_HANDFUL___ = 5  # expose whenever

    define_singleton_method :say_not_found, -> do

      say_not_found_via_a_and_k = _Say_not_found.curry[ _A_HANDFUL___ ]

      -> k, a do
        say_not_found_via_a_and_k[ a, k ]
      end
    end.call
  end
end
