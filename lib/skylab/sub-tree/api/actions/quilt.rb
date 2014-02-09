#!/usr/bin/env ruby -w

require 'optparse'
module Skylab
  class QuiltModified
    def description
      call_digraph_listeners(:help, "#{hdr 'description:'} reads a list of files from stdin, outputs a particular thing..")
    end
    def usage
      call_digraph_listeners(:help, "#{hdr 'usage:'} #{pre "#{program_name} [opts] <file1> [<file2> [..]]"} " <<
           "OR  #{pre "git ls-files -m | #{program_name} [opts]"}")
    end
    def optparse
      @optparse ||= OptionParser.new do |o|
        o.banner = hdr 'options:'
        o.on('-h', '--help', "this screen.") { help }
      end
    end
    def execute argv
      parse(argv) or return
      lines.each do |line|
        "git diff #{line} > #{line.gsub('/', '__')}.patch".tap do |cmd|
           call_digraph_listeners(:out, cmd)
        end
      end
    end
    def parse_argv argv
      lines = nil
      if instream.tty?
        if argv.empty?
          usage_error "expecting input from either STDIN or as <file1> [<file2] .."
        else
          lines = argv.dup.to_enum
          argv.clear
        end
      elsif argv.empty?
        lines = Enumerator.new do |y|
          instream.each_line { |l| l.chomp! ; y << l }
        end
      else
        usage_error "can't take input from both STDIN and as arguments <file1> [<file2] .."
      end
      @lines = lines
    end
    attr_reader :lines

    # below this line are candidates

    def info msg
      call_digraph_listeners :info, msg
    end
    def call_digraph_listeners type, msg
      _IO[ :out == type ? :outstream : :errstream  ].puts msg ; nil
    end
  private
    def instream
      _IO.instream
    end
    def _IO
      @IO ||= omg_really
    end
    def omg_really
      self._WAT  # look at the prev lines
    end
  public
    def help
      usage
      description
      call_digraph_listeners(:help, optparse.to_s)
      @done = true
    end
    def initialize
      @done = false
      @params = {}
    end
    def invite
      call_digraph_listeners(:help, "Use #{pre "#{program_name} -h"} for help.")
    end
    def parse argv
      begin
        optparse.parse!(argv)
      rescue OptionParser::ParseError => e
        return usage_error("#{e}")
      end
      (@done or ! parse_argv(argv)) and return false
      true
    end
    def program_name
      File.basename($PROGRAM_NAME)
    end
    def usage_error msg=nil
      call_digraph_listeners(:help, "#{program_name}: #{msg}") if msg
      usage
      invite
      false
    end

    _ = [nil, :strong, * Array.new(29), :red, :green, * Array.new(3), :cyan]
    MAP = Hash[ * _.each_with_index.map { |sym, idx| [sym, idx] if sym }.compact.flatten ]
    o = -> x, s do  # [#hl-029]
      "\e[#{ [ * x ].map( & MAP.method( :[] ) ).compact * ';' }m#{ s }\e[0m"
    end.curry
    define_method :pre, & o[ :green ]
    define_method :hdr, & o[ [ :strong, :green ] ]
  end
end

Skylab::QuiltModified.new.execute(ARGV)
