#!/usr/bin/env ruby -w
require 'fileutils'
require 'open3'
require 'optparse'
require 'pathname'
require 'shellwords'

module Skylab ; end
module Skylab::Tolerance
  module TiteColor
    _ = [nil, :strong, * Array.new(29), :red, :green, :yellow, :blue, :magenta, :cyan, :white]
    MAP = Hash[ * _.each_with_index.map { |sym, idx| [sym, idx] if sym }.compact.flatten ]
    def stylize str, *styles ; "\e[#{styles.map{ |s| MAP[s] }.compact.join(';')}m#{str}\e[0m" end
  end
  module Styles
    include TiteColor
    def pre(s) ; stylize(s, :green         ) end
    def hdr(s) ; stylize(s, :strong, :green) end
  end
  module ActionInstanceMethods
    include Styles
    def actions
      actions? or return nil
      ::Enumerator.new do |y|
        client_class::Actions.constants.each do |const|
          y << client_class::Actions.const_get(const).new # yes! the grand simplification
        end
      end
    end
    def actions?
      client_class.const_defined?(:Actions) or return nil
    end
    def argument_syntax
      s = argument_parameters.map do |type, name|
        case type
        when :opt  ; pre "[<#{name}>]"
        when :req  ; pre "<#{name}>"
        when :rest ; pre "[<#{name}> [<#{name}> [...]]]"
        else "#{ [type, name].inspect }" end
      end.join(' ')
      '' == s ? nil : s
    end
    def argument_parameters
      bound_method.parameters[0..(option_syntax? ? -2 : -1)]
    end
    def bound_method
      method :execute
    end
    def client_class
      self.class
    end
    def emit _, msg
      @parent.emit _, msg
    end
    def help
      emit :help, @option_parser.help
      throw :stop_parse
    end
    def invitation children=false
      if actions? and children
        "try #{pre "#{program_name} <action-name> -h"} for help on a particular action."
      else
        "try #{pre "#{program_name} -h"} for help."
      end
    end
    def invoke argv
      if actions?
        action = resolve(argv) or return
        action.parent!(self).invoke(argv)
      else
        parse_opts(argv) && parse_args(argv) or return
        bound_method.call(* (argv + [(opts if option_syntax?)].compact))
      end
    end
    def resolve argv
      parse_opts(argv) or return
      token = argv.shift or return syntax("expecting <action>: #{actions.map{ |a| pre a.name }.join(' or ')}")
      matcher = /^#{Regexp.escape token}/
      found = catch :exact_match do
        actions.reduce([]) do |m, a|
          a.name == token and throw(:exact_match, [a])
          a.name =~ matcher and m.push a
          m
        end
      end
      case found.size
      when 0 ; syntax("no such action: #{pre token}")
      when 1 ; found.first
      else   ; syntax("ambiguous action #{pre token} -- did you mean #{found.map{ |a| pre a.name }.join(' or ')}?")
      end
    end
    def name
      client_class.name.match(/[^:]+$/)[0].gsub(/(?<=[a-z])(?=[A-Z])/, '-').downcase
    end
    def option_parser
      option_syntax? or return nil
      @option_parser ||= ::OptionParser.new do |o|
        @opts = opts = {}
        o.banner = "#{usage}\n#{hdr 'options:'}"
        option_syntax o
        o.on('-h', '--help', 'this screen.') { help }
        o.release = 'alpha'
        o.version = '0.0.0'
        o.separator invitation(true)
      end
    end
    def option_syntax? # need to avoid circular dependency bwn option_parser and argument_syntax
      respond_to?(:option_syntax) or return nil
    end
    def parent! parent
      @parent = parent ; self
    end
    def parse_args argv
      parameters = self.argument_parameters
      ok = if (pp = parameters.select { |p| :req == p.first }).length > argv.length
        emit :missing_required_argument, "missing required argument: #{pre pp[argv.length].last}"
        false
      elsif argv.length > parameters.length and ! parameters.index{ |x| :rest == x.first }
        emit :unexpected_argument, "unexpected argument: #{pre argv[parameters.length]}"
        false
      else
        true
      end
      ok or begin
        emit :usage,  usage
        emit :invite, invitation
      end
      ok
    end
    def parse_opts argv
      option_syntax? or return true
      if actions?
        # parse_opts here iff there are any option-looking things before the first non-option looking thing
        md = nil ; argv.detect { |x| md = /^(?:(?<opt>-)|(?<arg>[^-]))/.match(x) } and md[:opt] or return true
      end
      catch(:stop_parse) { option_parser.parse!(argv) } or return nil
      true
    rescue ::OptionParser::ParseError => e
      emit :parse_error, e.message
      emit :usage,       usage
      emit :invite,      invitation
      false
    end
    attr_reader :opts
    def option_syntax_string
      option_syntax? or return nil
      pre '[opts]' # meh
    end
    def program_name
      "#{@parent.program_name} #{name}"
    end
    def syntax msg
      emit :syntax, msg
      emit :usage, usage
      emit :help, invitation
      false
    end
    def usage
      if actions?
        "#{hdr 'usage:'} #{program_name} {#{pre '<options>'} | {#{actions.map(&:name).join('|')}} [args]}"
      else
        ["#{hdr 'usage:'} #{program_name}",  argument_syntax, option_syntax_string].compact.join(' ')
      end
    end
  end
  class Runtime
    include ActionInstanceMethods
    def program_name ; File.basename($PROGRAM_NAME) end
  end
end

module Skylab::Guardfile
  module Models
  end
  class Models::Cluster < Struct.new(:path)
    def self.from_datastore data
      Enumerator.new do |y|
        data.each_line do |line|
          y << new(line)
        end
      end
    end
    def initialize path
      super path.chomp
    end
    alias_method :line, :path
    alias_method :string, :path
  end
  class Models::Cluster::Enumerator < ::Enumerator
    def from_filesystem pwd
      self.class.new do |y|
        pwd = Pathname.new(pwd)
        Open3.popen3("find #{Shellwords.shellescape pwd.to_s} -type dir -name test -depth 4") do |sin, sout, serr|
          sout.each_line do |line|
            pn = Pathname.new(line)
            pn = pn.relative_path_from(pwd)
            y << Models::Cluster.new(pn.to_s)
          end
          serr.each_line do |line|
            emit :stderr, line
          end
        end
      end
    end
  end
  class Models::DataFile
    def initialize parent
      @commit = true
      @fh = DATA
      @parent = parent
    end
    def each_line &b
      (@ram ||= @fh.each_line.map { |l| l }).each(&b)
    end
    def rewrite! nodes
      ram = nodes.map(&:line)
      ll = [] ; line = nil
      File.open(@fh.path) do |fh|
        ll.push(line) while line = fh.gets and "__END__\n" != line
        line == "__END__\n" or fail("__END__ hack failed")
        ll.push line
        ram[0..-2].each { |l| ll.push("#{l}\n") }
        ram.any? and ll.push ram.last
      end
      @commit and File.open(@fh.path, 'w') { |fh| ll.each { |l| fh.write l } }
      @ram = ram
    end
  end
  class CLI < ::Skylab::Tolerance::Runtime
    def emit _, msg      ; $stderr.puts(msg)  ; end
    def option_syntax o                       ; end
    module Actions                            ; end
  end
  class CLI::Action
    include ::Skylab::Tolerance::ActionInstanceMethods
    def clusters
      Models::Cluster.from_datastore(datastore)
    end
    def datastore
      @datastore ||= Models::DataFile.new(self)
    end
    def pwd
      FileUtils.pwd
    end
  end
  module CLI::UpdaterInstanceMethods
    def render_tagged c
      emit(:info, "#{c.last.path} #{send(c.first, "(#{c.first.to_s})")}")
    end
    def tagged
      # tag the union of existing and new nodes as follows: { new | ok | stale }
      # then sort them and print them
      existeds = clusters.to_a
      existed = Hash[* existeds.map { |c| [c.path, true] }.flatten(1) ]
      taggeds = []
      seen = {}
      clusters.from_filesystem(pwd).each do |c|
        seen[c.path] = true
        taggeds.push [existed[c.path] ? :ok : :new, c]
      end
      existeds.each { |c| seen[c.path] or taggeds.push([:stale, c]) }
      taggeds.sort_by { |c| c.last.path }
    end
    def new     str ; stylize str, :green               end
    def ok      str ; stylize str, :blue                end
    def stale   str ; stylize str, :yellow              end
  end
  class CLI::Actions::List < CLI::Action
    def option_syntax o ; end
    def execute opts
      clusters.each do |clust|
        emit(:payload, clust.string)
      end
    end
  end
  class CLI::Actions::Check < CLI::Action
    include CLI::UpdaterInstanceMethods
    def option_syntax o ; end
    def execute opts
      tagged.each { |c| render_tagged c }
    end
  end
  class CLI::Actions::Update < CLI::Action
    include CLI::UpdaterInstanceMethods
    def option_syntax o ; end
    def execute opts
      datastore.rewrite! tagged.map(&:last)
      tagged.each { |c| render_tagged c }
    end
  end
  class CLI::Actions::Prune < CLI::Action
  end
end

if __FILE__ == $PROGRAM_NAME
  ::Skylab::Guardfile::CLI.new.invoke(ARGV)
end

__END__
one
two
