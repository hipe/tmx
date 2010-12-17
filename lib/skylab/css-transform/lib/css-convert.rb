require 'rubygems'

$:.unshift(File.dirname(File.dirname(__FILE__))+'/vendor/lib/treetop/lib') 
  # use treetop in vendor/lib, not the one in rubygems/rvm/gemspec/whatever, in case etc.. @todo

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
  ROOT = File.dirname(__FILE__)+'/css-convert'
  class << self
    def cli
      Cli.new
    end
    def css_parser
      CssParser.new
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
  module Grammars
    class << self
      #
      # if we've compiled the grammar ourselves, load that else let treetop do it.
      # (Surprised this isn't builtin to treetop!)
      #
      def load str
        if File.exist?("#{str}.rb")
          require str
        else
          ::Treetop.load(str)
        end
      end
    end
  end
end

require Hipe::CssConvert::ROOT+'/runtime.rb'
require Hipe::CssConvert::ROOT+'/sexpie.rb'
require Hipe::CssConvert::ROOT+'/node-classes.rb'
require Hipe::CssConvert::ROOT+'/css-parser.rb'
