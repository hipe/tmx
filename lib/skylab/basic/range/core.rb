module Skylab::Basic

  module Range  # see [#035]

    # needs its own anemic file because alphabet

    class << self

      def normalization
        Range_::Normalization__
      end
    end

    Range_ = self
  end
end
