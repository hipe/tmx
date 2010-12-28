module Hipe::CssConvert
  module InterfaceReflector
    class << self
      def extended cls
        cls.extend ClassMethods
        cls.send(:include, InstanceMethods)
      end
    end
  end
end

module Hipe::CssConvert::InterfaceReflector
  module InstanceMethods
    def build_cli_option_parser
      require 'optparse'
      OptionParser.new do |o|
        o.banner = usage
        self.class.interface.parameters.select{ |p| p.cli? and p.option? }.
        each do |p|
          o.on( * p.cli_definition_array ){ |v| dispatch_option(p, v) }
        end
      end
    end
    def dispatch_option parameter, value
      args = parameter.takes_argument? ? [value] : []
      send("on_#{parameter.intern}", *args)
    end
  end
  module ClassMethods
    def interface
      @interface ||= build_interface
    end
  end
end

module Hipe::CssConvert::InterfaceReflector
  class ParameterDefinitionSet < Array
    def initialize
      @parsed = false
    end
    def each &b;        @parsed or parse!;         super(&b)     end
    def select &b;      @parsed or parse!;         super(&b)     end
  private
    def parse!
      each_index do |idx|
        self[idx] = self[idx].parse
      end
      @parsed = true
    end
  end
end

module Hipe::CssConvert::InterfaceReflector
  class Parameter
    def initialize intern
      @intern = intern
      block_given? and yield self
    end
    def cli?                ;   instance_variable_defined?('@is_cli')      end
    def cli!                ;   @is_cli = true;                            end
    def noable!             ;   @noable = true;                            end
    def argument_required!  ;   @argument = :required                      end
    def argument_optional!  ;   @argument = :optional                      end
    def takes_argument?     ;   instance_variable_defined?('@argument')    end
    def option!             ;   @option   = true                           end
    def required!           ;   @required = true                           end
    def optional?           ;  !required?                                  end
    def argument?           ;  !option?                                    end

    attr_reader   :intern
    attr_accessor :cli_definition_array, :cli_syntax_label, :cli_label
    attr_reader   :argument
    attr_reader   :option
    alias_method  :option?, :option
    attr_reader   :required
    alias_method  :required?, :required
  end
end

module Hipe::CssConvert::InterfaceReflector
  class RequestParser
    # an adapter to make it look like an option parser, but it's more
    def initialize
      @parameters = ParameterDefinitionSet.new
      yield self
    end
    attr_reader :parameters
    def on *a
      @parameters.push UnparsedOptionDefinition.new(a)
    end
    def arg *a
      @parameters.push UnparsedArgumentDefinition.new(a)
    end
  end
  class RequestParser
    class UnparsedParameterDefinition
      def initialize(arr)
        @arr = arr
      end
    end
    class UnparsedOptionDefinition < UnparsedParameterDefinition
      def parse
        found = @arr.detect{ |x| x.kind_of?(String) && 0 == x.index('--') }
        found or fail("Must have --long option name in: #{@arr.inspect}")
        md = %r{\A--(\[no-\])?([^=\[ ]+)
          (?:  \[[ =](<?[^ >]+>?)?\]
            |   [ =] (<?[^ >]+>?)?
          )?
        \Z}x.match(found)
        md or fail("regexp match failure with: #{@arr.inspect}")
        intern = md[2].gsub('-','_').intern
        Parameter.new(intern) do |p|
          p.cli!; p.option!
          p.cli_syntax_label = @arr.first
          md[1].nil? or p.noable!
          md[3].nil? or p.argument_optional!
          md[4].nil? or p.argument_required!
          p.cli_definition_array = @arr
        end
      end
    end
    class UnparsedArgumentDefinition < UnparsedParameterDefinition
      def parse
        md = %r{\A (
            \[  ( <? ([a-z0-9][-_a-z0-9]*) >?  ) \]
          |     ( <? ([a-z0-9][-_a-z0-9]*) >?  )
        ) \Z}ix.match(@arr.first)
        md or fail("expecting \"foo\" or \"[foo]\", not "<<
          " #{@arr.first.inspect}")
        intern = (md[3] || md[5]).gsub('-','_').intern
        Parameter.new(intern) do |p|
          p.cli!; p.cli_syntax_label = md[1]
          p.cli_label = (md[2] || md[4])
          p.argument_required! # always true for arguments
          md[2].nil? and p.required!
        end
      end
    end
  end
end

module Hipe::CssConvert::InterfaceReflector
  module CliInstanceMethods
    def run argv
      @argv = argv
      @c = build_context
      @exit_ok = nil
      @queue = []
      begin
        cli_option_parser.parse!(argv)
        @queue.push default_action
        catch(:early_exit){ @queue.each{ |meth| send meth } }
      rescue OptionParser::ParseError => e
        error e.message
      end
    end
    attr_accessor :c
    alias_method :execution_context, :c
  protected
    Codes = {:bold=>1,:dark_red=>31,:green=>32,:yellow=>33,:blue=>34,
      :purple=>35,:cyan=>36,:white=>37,:red=>38}
    def color(s, *a); "\e[#{a.map{|x|Codes[x]}.compact*';'}m#{s}\e[0m" end
    def em(s); style(s, :em) end
    Styles = { :error => [:bold, :red], :em => [:bold, :green] }
    def style(s, style); color(s, *Styles[style]) end
    def error msg
      @c.err.puts msg
      @c.err.puts usage
      @c.err.puts invite
    end
    def cli_option_parser
      @cli_option_parser ||= build_cli_option_parser
    end
    def fatal msg
      @c.err.puts msg
      throw :early_exit
    end
    def invite
      em("#{program_name} -h") << " for help"
    end
    def on_help
      @c.err.puts cli_option_parser.to_s
      @exit_ok = true
    end
    def on_version
      @c.err.puts "#{program_name} #{version_string}"
      @exit_ok = true
    end
    def program_name
      File.basename($PROGRAM_NAME)
    end
    def usage_syntax_string
      [program_name,options_syntax_string,arguments_syntax_string].compact*' '
    end
    def options_syntax_string
      s = self.class.interface.parameters.select{ |p| p.cli? && p.option? }.
      map{ |p| "[#{p.cli_syntax_label}]" }.join(' ')
      s unless s.empty?
    end
    def arguments_syntax_string
      s = self.class.interface.parameters.select{ |p| p.cli? && p.argument? }.
      map(&:cli_syntax_label).join(' ')
      s unless s.empty?
    end
    def usage
      "#{em('usage:')} #{usage_syntax_string}"
    end
  end
end
