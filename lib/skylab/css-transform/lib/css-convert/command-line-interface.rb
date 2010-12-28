module Hipe::CssConvert
  require ROOT + '/core-interface'

  class CommandLineInterface < CoreInterface
    include InterfaceReflector::CliInstanceMethods
    def default_action;      :run_convert                               end
  end
end
