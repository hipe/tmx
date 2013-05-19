module Skylab::TestSupport::Regret::API

  module API::Conf

    def self.Verbosity action_class
      Verbosity.enhance_action_class action_class
      nil
    end

    Verbosity = API::Support::Verbosity::Graded :everything, :medium, :murmur
    # NOTE the order of the symbols above corresponds to the number of "-v"'s !

  end
end
