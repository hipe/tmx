module Skylab::Face

  module API::Client::Metastory

    def self.touch ; nil end      #kick-the-loading-warninglessly-and-trackably

  end

  class API::Client

    Face_::Metastory.enhance self, :API_, :Modality_Client_

  end
end
