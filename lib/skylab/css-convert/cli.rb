module Skylab::CssConvert
  require ROOT + '/core-interface'

  class CommandLineInterface < CoreInterface
    include InterfaceReflector::CliInstanceMethods

    alias_method :on_version, :_on_version
  end
end
