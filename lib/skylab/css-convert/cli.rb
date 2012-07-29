module Skylab::CssConvert
  class CLI < Core
    extend ::Skylab::Autoloader
    extend  InterfaceReflector::CLI::ModuleMethods
    include InterfaceReflector::CLI::InstanceMethods

    def output_adapter
      @output_adapter ||= CLI::OutputAdapter.new
    end
    attr_writer :output_adapter
  end
end
