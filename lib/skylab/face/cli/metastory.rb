module Skylab::Face

  module CLI::Metastory  # [#fa-035]
    def self.touch  # just used for loading the library
    end
  end

  class CLI
    Face::Metastory.enhance self, :CLI_, :Modality_Client_
  end

  class Namespace
    Face::Metastory.enhance self, :CLI_, :Namespace_
  end

  class NS_Sheet_
    Face::Metastory.enhance self, :CLI_, :Namespace_
  end

  class Command
    Face::Metastory.enhance self, :CLI_, :Action_
  end

  #  class Cmd_Sheet_  # #todo only when needed
  #    Face::Metastory.enhance self, :CLI_, :Action_
  #  end
end
