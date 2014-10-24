module Skylab::Test

  module Adapters_::Relish

    # we use a strange name as an exercise in modularity, and so we don't
    # get false-positives when searching for the real ::R-Spec/r-spec

    Test_::Adapter_.anchor_module self  # do all the common things

    class << self

      def load_core_if_necessary
        if ! defined? ::Rspec
          Autoloader_.require_stdlib :RSpec
        end ; nil
      end
    end
  end
end
