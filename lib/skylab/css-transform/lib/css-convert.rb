# require 'rubygems'; require 'ruby-debug'; $stderr.puts "\e[1;5;33mruby-debug\e[0m"

module Hipe; end

module Hipe::CssConvert
  ROOT    = File.dirname(__FILE__)+'/css-convert'
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
