module Skylab::TestSupport

  class Tree_Runner

    class Adapters_::Relish < Tree_Runner_::Adapter_

  # we use a strange name as an exercise in modularity, and so we don't
  # get false-positives when searching for the real ::R-Spec/r-spec

      def load_core_if_necessary

        if ! defined? ::Rspec
          Autoloader_.require_stdlib :RSpec
        end ; nil
      end
    end
  end
end
