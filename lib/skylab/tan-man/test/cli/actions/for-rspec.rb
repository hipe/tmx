module Skylab::TanMan::TestSupport::CLI

  shared_context cli_action: true do
    before do
      api.clear # configs are memoized!
    end
  end
end
