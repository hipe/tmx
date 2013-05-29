module Skylab::Face

  module API::Action::Metastory

    def self.touch  # just used for loading the library
    end

  end

  class API::Action

    Face::Metastory.enhance self, :API_, :Action_

  end
end
