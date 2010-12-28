module Hipe; end
module Hipe::CssConvert
  ROOT    = File.dirname(__FILE__)+'/css-convert'
  VERSION = '0.0.0'
  class << self
    def cli
      @cli ||= begin
        require ROOT + '/command-line-interface'
        CommandLineInterface.new
      end
    end
  end
end
