module Skylab::Basic

  module Range  # see [#035]

    # #todo this file. whatever this means it's probably not relevant:
    # needs its own anemic file because alphabet

    class << self

      def normalize_qualified_knownness qkn, * x_a, & p
        x_a.push :qualified_knownness, qkn
        Here_::Normalization.call_via_iambic x_a, & p
      end
    end  # >>

    Here_ = self
  end
end
