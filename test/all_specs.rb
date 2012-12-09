#!/usr/bin/env ruby -w

require_relative '../lib/skylab'
require 'skylab/face/core' # only for MyPathname and Tableize::I_M
require 'skylab/headless/core' # only for require_quietly
require 'optparse'

module Skylab::Test

  Face = ::Skylab::Face
  Headless = ::Skylab::Headless

  class HeadlessClient < ::Struct.new(:queue, :submodules)
    protected
    def initialize
      super [], []
    end
    def add_skip name
      (@skip ||= { })[name.intern] = true
    end
    def find_submodules
      list = [] ; hash = {}
      submodule_paths.each do |dirpath|
        o = Submodule.new(File.basename(dirpath).intern, dirpath)
        list[hash[o.name] = list.length] = o
        if (testdir = o.inferred_testdir).exist?
          a = Face::MyPathname.glob(o.inferred_testdir.join('**/*_spec.rb'))
          unless a.empty?
            o.spec_subdir = testdir
            o.spec_paths = a
          end
        end
      end
      [list, hash]
    end
    def gemroot
      @gemroot ||= Face::MyPathname.new(::File.expand_path('../..', __FILE__))
    end

    attr_reader :skip

    def spec_paths                # experimentally big and functional
      match = if skip
        h = skip
        -> sym { ! h[sym] }
      elsif only
        h = ::Hash[ only.map { |x| [x.intern, true] } ]
        -> sym { h[sym] }
      else
        -> sym { true }
      end
      visit_submodule = -> y, submodule do
        if substring
          submodule.spec_paths.each do |p|
            if p.to_s.include? substring
              y << p
            else
              self.ignored_count += 1
            end
          end
        else
          submodule.spec_paths.each { |p| y << p }
        end
      end
      valid = -> seen do
        ok = true
        if skip
          if (bad = skip.keys - seen).length.nonzero?
            ok = bad_skip seen, bad
          end
        elsif only
          if (bad = only - seen).length.nonzero?
            ok = bad_only seen, bad
          end
        end
        ok
      end
      ::Enumerator.new do |y|
        seen = [ ] ; self.ignored_count = 0
        atom = submodules.reduce [] do |m, submodule|
          seen.push submodule.name
          if match[ submodule.name ]
            m.push submodule
          end
          m
        end
        ok = valid[ seen ]
        if ok
          atom.each { |s| visit_submodule[ y, s ] }
        end
        nil
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
      Face::MyPathname.glob(gemroot.join('lib/skylab/*'))
    end
    def write_files_list
      specs = submodules.reduce([]) do |a, submodule|
        a.concat submodule.spec_paths ; a
      end
      if specs.empty?
        info "No specs found!"
      else
        info "These are the spec files:"
        specs.each { |s| emit(:payload, s.pretty) }
      end
    end
  end
  class Submodule < ::Struct.new :name, :pathname, :spec_subdir, :spec_paths
    def inferred_testdir
      pathname.join 'test'
    end
    def num_test_files
      spec_paths && spec_paths.length or 0
    end
    protected
    def initialize name, pathname
      super(name, Face::MyPathname.new(pathname), nil, [])
    end
  end
  module CLI_InstanceMethods
    include Face::CLI::Tableize::InstanceMethods
    protected
    def initialize o = $stdout, e = $stderr
      super()
      @infostream = e
      @emit_f = ->(type, data) { (:payload == type ? o : e).puts data }
    end
    def actions
      @actions ||= self.class.public_instance_methods(false) - [:invoke]
    end
    def em s ; "\e[1;32m#{s}\e[0m" end
    def emit type, data ; @emit_f.call(type, data) end
    def help
      info option_parser.banner
      option_parser.summarize { |s| info s }
    end
    def info msg
      emit :info, msg
      nil
    end
    attr_reader :infostream
    def option_parser
      @option_parser ||= build_option_parser
    end
    def parse_opts argv
      option_parser.parse! argv
      true
    rescue ::OptionParser::ParseError => e
      usage e
    end
    def program_name ; @option_parser.program_name end
    def usage msg
      emit(:error, msg)
      info usage_line
      info "See #{em "#{program_name} -h"} for more help."
      false
    end
    def usage_line
      "#{ em 'Usage:' } #{ option_parser.program_name } [opts] #{
        }[[#{ actions.join '|' }] [..]] [subproduct [subproduct [..]]]"
    end
  end
  class CLI < HeadlessClient
    include CLI_InstanceMethods
    def invoke argv
      result = nil
      begin
        if :cli == run_mode
          parse_opts argv or break
          loop do
            argv.empty? and break
            if actions.include? argv.first.intern
              queue.push argv.shift.intern
            else
              break
            end
          end
          if ! argv.empty?
            @only = argv.map(&:intern) # can u guess what [*argv] does
            argv.clear # whatever just trying to be polite
          end
          if skip and only
            result = usage "can't use --skip along with subproduct names."
            break
          end
        end
        if queue.empty?
          queue.push default_action_name
        end
        result = queue.reduce nil do |_, action|
          r = send action
          r
        end
      end while nil
      result
    end
  public # the actions
    def counts
      tableize(::Enumerator.new do |y|
        total = 0
        submodules.each do |o|
          total += (cnt = o.num_test_files)
          y << { submodule: o.name.to_s, num_test_files: cnt }
        end
        y << { submodule: '(total)', num_test_files: total }
      end) { |line| info line }
      true
    end
    def files
      spec_paths.each { |p| emit(:payload, p.pretty) }
      if substring
        report_ignored
      end
      true
    end
    def req
      Headless::FUN.require_quietly[ 'rspec' ]
      _req
      true
    end
  protected
    def initialize
      super
    end
    bad_msg = -> name, all, bad do
      "bad #{ name } name(s) - couldn't find #{ bad.join ', ' } #{
        }among (#{ all.join ', ' }).  skipping all."
    end
    define_method :bad_only do |all, bad|
      infostream.write bad_msg[ 'subproduct', all, bad ]
      nil
    end
    protected :bad_only
    define_method :bad_skip do |all, bad|
      infostream.write bad_msg[ 'skip', all, bad ]
      nil
    end
    protected :bad_skip
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
      o.on('-s', '--substring <substr>',
             "if present, only load spec files",
             "whose [pretty] name includes substr") { |s| self.substring = s }
      o.on('--not <sub-product>', 'skip this sub-product',
             "(can specified multiple. exact match norm'd subproduct name)"
          ) { |x| add_skip x.intern }
      o.on('-v', '--verbose', "(things like output filenames)") do
        self.verbose = true
      end
      o
    end
    def default_action
      if :cli == run_mode
        require 'rspec/autorun'
      end
      if [:cli, :rspec].include? run_mode
        req
      end
      true
    end
    def default_action_name
      :default_action
    end
    attr_accessor :ignored_count
    attr_reader :only
    def _req
      count = 0
      if ! verbose
        infostream.write '('
      end
      spec_paths.each do |p|
        count += 1
        if verbose
          info "   #{em '>>>'} #{p}"
        else
          infostream.write '.'
        end
        require p.to_s
      end
      if verbose
        if substring
          report_ignored
        end
      else
        infostream.write " loaded #{count} spec files)\n\n"
      end
      nil
    end
    def report_ignored
      info "(ignored the #{ignored_count} files that lacked #{
        }#{substring.inspect} in the name.)"
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

::Skylab::Test::CLI.new.invoke ARGV
