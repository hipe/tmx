#!/usr/bin/env ruby -w

require 'optparse'
module Skylab
  class QuiltModified
    def description
      emit(:help, "#{hdr 'description:'} reads a list of files from stdin, outputs a particular thing..")
    end
    def usage
      emit(:help, "#{hdr 'usage:'} #{pre "#{program_name} [opts] <file1> [<file2> [..]]"} " <<
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
           emit(:out, cmd)
        end
      end
    end
    def parse_argv argv
      lines = nil
      if $stdin.tty?
        if argv.empty?
          usage_error "expecting input from either STDIN or as <file1> [<file2] .."
        else
          lines = argv.dup.to_enum
          argv.clear
        end
      elsif argv.empty?
        lines = Enumerator.new do |y|
          $stdin.each_line { |l| l.chomp! ; y << l }
        end
      else
        usage_error "can't take input from both STDIN and as arguments <file1> [<file2] .."
      end
      @lines = lines
    end
    attr_reader :lines

    # below this line are candidates

    def info msg
      emit :info, msg
    end
    def emit type, msg
      (:out == type ? $stdout : $stderr).puts msg
    end
    def help
      usage
      description
      emit(:help, optparse.to_s)
      @done = true
    end
    def initialize
      @done = false
      @params = {}
    end
    def invite
      emit(:help, "Use #{pre "#{program_name} -h"} for help.")
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
      emit(:help, "#{program_name}: #{msg}") if msg
      usage
      invite
      false
    end

    _ = [nil, :strong, * Array.new(29), :red, :green, * Array.new(3), :cyan]
    MAP = Hash[ * _.each_with_index.map { |sym, idx| [sym, idx] if sym }.compact.flatten ]
    def stylize str, *styles ; "\e[#{styles.map{ |s| MAP[s] }.compact.join(';')}m#{str}\e[0m" end # [#sc-001]
    def pre s ; stylize(s, :green)  end
    def hdr s ; stylize(s, :strong, :green) end
  end
end

Skylab::QuiltModified.new.execute(ARGV)

