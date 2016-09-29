module Skylab::Common::TestSupport

  module FixtureTree::For_Skerlerb

      dpn = TS_.dir_pathname.join 'fixture-tree/for-skerlerb'
      define_singleton_method :dir_pathname do dpn end

  end
end
