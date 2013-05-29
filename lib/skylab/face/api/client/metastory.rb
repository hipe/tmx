module Skylab::Face

  module API::Client::Metastory

    def self.touch  # just used for loading the library
    end

  end

  class API::Client

    Face::Metastory.enhance self, :API_, :Modality_Client_

  end
end
