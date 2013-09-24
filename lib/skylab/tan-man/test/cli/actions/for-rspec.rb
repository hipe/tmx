module Skylab::TanMan::TestSupport::CLI

  shared_context cli_action: true do
    before do
      clear_api_if_necessary
    end
  end
end
