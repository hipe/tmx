module Skylab::Basic

  module Range  # see [#035]

    # needs its own anemic file because alphabet

    class << self

      def normalization
        Range_::Normalization__
      end

      def normalize_argument arg, * x_a, & oes_p
        x_a.push :arg, arg
        Range_::Normalization__.call_via_iambic x_a, & oes_p
      end
    end

    Range_ = self
  end
end
