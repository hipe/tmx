module Skylab::Basic

  module Range  # see [#035]

    # needs its own anemic file because alphabet

    class << self

      def normalize_qualified_knownness qkn, * x_a, & oes_p
        x_a.push :qualified_knownness, qkn
        Here_::Normalization.call_via_iambic x_a, & oes_p
      end
    end  # >>

    Autoloader_[ self ]
    lazily :Normalization do
      Here_::Normalization__
    end

    Here_ = self
  end
end
