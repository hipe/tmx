module Hipe::CssConvert
  require ROOT + '/core-interface'

  class CommandLineInterface < CoreInterface
    include InterfaceReflector::CliInstanceMethods

  private

    def usage_syntax_string; "#{program_name} [opts] <command-file>" end
    def default_action;      :run_convert                            end

  end
end
