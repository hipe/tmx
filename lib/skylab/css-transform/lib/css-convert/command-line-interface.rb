module Hipe::CssConvert
  require ROOT + '/core-interface'

  class CommandLineInterface < CoreInterface
    include InterfaceReflector::CliInstanceMethods
  end
end
