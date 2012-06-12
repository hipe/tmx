module Skylab::Treemap
  class Actions::Render < Action
    def execute
      r.ready? or return error(r.not_ready_reason)
      emit(:payload, "here is some payload")
    end
  end
end

