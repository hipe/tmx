module Skylab::TestSupport

  module Regret::API

  module Support::Verbosity

    # `self.Graded` - pass this only a list of symbols and it will produce a
    # module suitable to be stored your e.g your Conf module (for static,
    # load-time conf). see downstream for capabilities of the module.

    def self.Graded *grade_i_a

      Support::Verbosity::Graded.produce_conf_module grade_i_a

    end
  end
  end
end
