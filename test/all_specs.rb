#!/usr/bin/env ruby -w

require_relative '../lib/skylab'
require 'skylab/face/cli/tableize'
require 'skylab/face/core'
require 'optparse'

module Skylab end
module Skylab::Test
  class HeadlessClient < ::Struct.new(:queue, :submodules)
    protected
    def initialize ; super([], []) end
    def find_submodules
      list = [] ; hash = {}
      submodule_paths.each do |dirpath|
        o = Submodule.new(File.basename(dirpath).intern, dirpath)
        list[hash[o.name] = list.length] = o
        if (testdir = o.inferred_testdir).exist?
          a = MyPathname.glob(o.inferred_testdir.join('**/*_spec.rb'))
          unless a.empty?
            o.spec_subdir = testdir
            o.spec_paths = a
          end
        end
      end
      [list, hash]
    end
    def gemroot
      @gemroot ||= MyPathname.new(::File.expand_path('../..', __FILE__))
    end
    def spec_paths
      ::Enumerator.new do |y|
        self.ignored_count = 0
        submodules.each do |submodule|
          submodule.spec_paths.each do |p|
            if substring
              if p.to_s.include?(substring)
                y << p
              else
                self.ignored_count += 1
              end
            else
              y << p
            end
          end
        end
      end
    end
    def submodules
      @hash ||= begin # apology
        self.submodules, hash = find_submodules
        hash
      end
      super
    end
    def submodule_paths
      MyPathname.glob(gemroot.join('lib/skylab/*'))
    end
    def write_files_list
      specs = submodules.reduce([]) do |a, submodule|
        a.concat submodule.spec_paths ; a
      end
      if specs.empty?
        emit(:info, "No specs found!")
      else
        emit(:info, "These are the spec files:")
        specs.each { |s| emit(:payload, s.pretty) }
      end
    end
  end
  MyPathname = ::Skylab::Face::MyPathname
  class Submodule < ::Struct.new(:name, :pathname, :spec_subdir, :spec_paths)
    def inferred_testdir ; pathname.join('test') end
    def num_test_files
      spec_paths && spec_paths.length or 0
    end
    protected
    def initialize name, pathname
      super(name, MyPathname.new(pathname), nil, [])
    end
  end
  module CLI_InstanceMethods
    include ::Skylab::Face::CLI::Tableize::InstanceMethods
    protected
    def initialize o = $stdout, e = $stderr
      super()
      @errstream = e
      @emit_f = ->(type, data) { (:payload == type ? o : e).puts data }
    end
    def actions
      self.class.public_instance_methods(false) - [:invoke]
    end
    def em s ; "\e[1;32m#{s}\e[0m" end
    def emit type, data ; @emit_f.call(type, data) end
    attr_reader :errstream
    def help
      emit(:info, option_parser.banner)
      option_parser.summarize { |s| emit(:info, s) }
    end
    def option_parser ; @option_parser ||= build_option_parser end
    def parse_opts argv
      option_parser.parse!(argv)
      true
    rescue ::OptionParser::ParseError => e
      usage e
    end
    def program_name ; @option_parser.program_name end
    def usage msg
      emit(:error, msg)
      emit(:info, usage_line)
      emit(:info, "See #{em "#{program_name} -h"} for more help.")
      false
    end
    def usage_line
      "#{em 'Usage:'} " <<
        "#{option_parser.program_name} [opts] [#{actions.join('|')}]"
    end
  end
  class CLI < HeadlessClient
    include CLI_InstanceMethods
    def invoke argv
      if :cli == run_mode
        parse_opts(argv) or return
        queue.concat argv # any
        if ! argv.empty?
          if ! (bad = argv - actions.map(&:to_s)).empty?
            return usage("unrecogized action(s): #{bad.join(', ')}")
          end
        end
      end
      queue.empty? and queue.push(default_action_name)
      last = nil
      last = send(queue.shift) until queue.empty?
      last
    end
    def counts
      tableize(::Enumerator.new do |y|
        total = 0
        submodules.each do |o|
          total += (cnt = o.num_test_files)
          y << { submodule: o.name.to_s, num_test_files: cnt }
        end
        y << { submodule: '(total)', num_test_files: total }
      end) { |line| emit(:info, line) }
      true
    end
    def files
      spec_paths.each { |p| emit(:payload, p.pretty) }
      substring and report_ignored
      true
    end
    def req
      requiet('rspec')
      _req
      true
    end
    protected
    def build_option_parser
      @option_parser = o = ::OptionParser.new
      o.banner = usage_line
      o.separator(
        "#{em 'Description:'} runs all known tests in the skylab universe.")
      o.separator <<-HERE.gsub(/^#{' '*6}/, '')
      #{em 'Actions:'}
          counts    show a report of number of tests per submodule
          files     write to stdout the pretty name of each test file
          req       require() each file (but do not require 'rspec/autorun')
      #{em 'Options:'}
      HERE
      o.on('-h', '--help', "This screen.") do
        queue.push :help
      end
      o.on('-s', '--substring <substr>', 'if present, only load spec ' <<
        'files whose [pretty] name include substr') { |s| self.substring = s }
      o.on('-v', '--verbose', "(things like output filenames)") do
        self.verbose = true
      end
      o
    end
    def default_action
      :cli == run_mode and require('rspec/autorun')
      [:cli, :rspec].include?(run_mode) and req
      true
    end
    def default_action_name ; :default_action end
    attr_accessor :ignored_count
    def _req
      count = 0
      verbose or errstream.write('(')
      spec_paths.each do |p|
        count += 1
        verbose ? emit(:info, "   #{em '>>>'} #{p}") : errstream.write('.')
        require p.to_s
      end
      substring && verbose and report_ignroed
      verbose or errstream.write(" loaded #{count} spec files)\n\n")
    end
    def requiet zoop
      v = $VERBOSE ; $VERBOSE = false ; require(zoop) ; $VERBOSE = v
    end
    def report_ignored
      emit(:info, "(ignored the #{ignored_count} files that lacked " <<
        "#{substring.inspect} in the name.)")
    end
    def run_mode
      @run_mode ||= (
      if __FILE__ == $PROGRAM_NAME then :cli
      elsif %r{/rspec$} =~ $PROGRAM_NAME then :rspec # ick
      else :none end )
    end
    attr_accessor :substring
    attr_accessor :verbose
  end
end

::Skylab::Test::CLI.new.invoke(ARGV)
