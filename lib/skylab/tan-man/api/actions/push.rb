module Skylab::TanMan
  module Api::Actions
    Push = ->(runtime, req) do
      runtime.emit(:info, "pretending to push: #{req.inspect}")
    end
  end
end

