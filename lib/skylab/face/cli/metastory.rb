class Skylab::Face::CLI

    module CLI::Metastory  # [#035]
      def self.touch ; nil end      #kick-the-loading-warninglessly-and-trackably
    end

    class CLI
      Face_::Metastory.enhance self, :CLI_, :Modality_Client_
    end

    class Namespace
      Face_::Metastory.enhance self, :CLI_, :Namespace_
    end

    class NS_Sheet_
      Face_::Metastory.enhance self, :CLI_, :Namespace_
    end

    class Command
      Face_::Metastory.enhance self, :CLI_, :Action_
    end

    #  class Cmd_Sheet_  # #todo only when needed
    #    Face::Metastory.enhance self, :CLI_, :Action_
    #  end
end
