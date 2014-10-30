module Skylab::Basic

  module Range  # see [#035]

    # needs its own anemic file because alphabet

    class << self

      def normalization
        Range_::Normalization__
      end

      def normalize arg, * x_a, event_p
        x_a.push :arg, arg, :on_event, event_p
        Range_::Normalization__.via_iambic x_a
      end
    end

    Range_ = self
  end
end
