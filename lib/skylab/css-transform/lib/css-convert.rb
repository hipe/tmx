require 'treetop'
require 'stringio'

module Hipe;
  class MyStringIO < StringIO
    # override useless flush of StringIO
    def flush
      rewind
      read
    end
  end
end
module Hipe::CssConvert
  class << self
    def cli
      Cli.new
    end
  end
  class Cli
    def initialize
      @out = $stdout
      @err = $stderr
    end
    def buffered!
      @out = Hipe::MyStringIO.new
      @err = Hipe::MyStringIO.new
      self
    end
    attr_accessor :out, :err
    def run argv
      if 1 != argv.size
        @out.puts "Usage: #{$PROGRAM_NAME} [file]"
        return 1;
      end
      file = argv.shift
      a = Agent.new(self)
      return a.run(file)
    end
  end
  class Agent
    def initialize ui
      @out = ui.out
      @err = ui.err
    end
    def run file
      if ! File.exist?(file)
        @err.puts "File not found: #{file}"
        return 1
      end
    end
  end
end
