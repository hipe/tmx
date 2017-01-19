require_relative '../test-support'

module Skylab::Plugin::TestSupport

  describe "[pl] depdendencies" do

    TS_[ self ]
    use :dependencies

    # (will rewrite)

  end
end
# #tombstone-A: full reconception of "dependencies" as "lazy-index"
