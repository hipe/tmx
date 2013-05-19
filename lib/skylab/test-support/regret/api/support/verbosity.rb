module Skylab::TestSupport::Regret::API

  module Support::Verbosity

    def self.Graded *grade_i_a

      Support::Verbosity::Graded.create grade_i_a

    end
  end
end
