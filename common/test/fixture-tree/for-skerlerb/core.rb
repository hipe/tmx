module Skylab::Common::TestSupport

  module FixtureTree::For_Skerlerb

    path = ::File.join TS_.dir_path, 'fixture-tree', 'for-skerlerb'

    define_singleton_method :dir_path do
      path
    end
  end
end
