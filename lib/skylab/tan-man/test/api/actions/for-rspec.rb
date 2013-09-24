module Skylab::TanMan::TestSupport::API::Actions

  shared_context api_action: true do
    before do
      clear_api_if_necessary
    end
  end
end
