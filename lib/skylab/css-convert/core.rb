module Skylab::CssConvert
  ROOT = File.dirname(__FILE__)
  class << self
    def cli
      @cli ||= begin
        require ROOT + '/command-line-interface'
        CommandLineInterface.new
      end
    end
  end
  class ExecutionContext < Hash
    def initialize
      @out = $stdout
      @err = $stderr
    end
    attr_reader :out, :err
  end
end
