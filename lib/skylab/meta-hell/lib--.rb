module Skylab::MetaHell

  module Lib__

    # (this file is :+#temporary-to-this-phase.)

    Say_not_found_ = -> d, a, k do

      s = MetaHell_.lib_.levenshtein.with(
        :item, k,
        :items, a,
        :closest_N_items, d,
        :aggregation_proc, -> a_ { a_ * ' or ' } )

      if s
        _did_you_mean = " - did you mean #{ s }?"
      end

      "not found #{ MetaHell_.lib_.strange k }#{ _did_you_mean }"
    end

    A_HANDFUL_ = 5

    Say_not_found = Say_not_found_.curry[ A_HANDFUL_ ]
  end
end
