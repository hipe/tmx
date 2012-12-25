module Skylab::TanMan::TestSupport::API::Actions

  shared_context api_action: true do
    before do
      api.clear_all_services # configs are memoized!
      self.api_was_cleared = true # just for finding this
    end
  end
end
