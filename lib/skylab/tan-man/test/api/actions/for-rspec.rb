module Skylab::TanMan::TestSupport::API::Actions

  shared_context api_action: true do
    before do
      api.clear # configs are memoized!
    end
  end
end
