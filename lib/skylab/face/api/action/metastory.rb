module Skylab::Face

  module API::Action::Metastory

    def self.touch ; nil end      #kick-the-loading-warninglessly-and-trackably

  end

  class API::Action

    Face::Metastory.enhance self, :API_, :Action_

  end
end
