require 'optparse'

module Skylab ; end
module Skylab::Tolerance
  Stylize_ = -> do
    _ = [ nil, :strong, * ::Array.new( 29 ), :red, :green, :yellow, :blue, :magenta, :cyan, :white ]
    map = ::Hash[ * _.each_with_index.map { |sym, idx| [ sym, idx ] if sym }.compact.flatten ]
    -> a, str do
      "\e[#{ a.map( & map.method( :[] ) ).compact * ';' }m#{ s }\e[0m"  # [#hl-029]
    end
  end.call
  module Styles
    include My_TiteColor
    o = Stylize_.curry
    define_method :pre, & o[ %i| green | ]
    define_method :hdr, & o[ %| strong green | ]
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
        @opts = { }
        o.banner = "#{usage}\n#{hdr 'options:'}"
        option_syntax o
        o.on('-h', '--help', 'this screen.') { help }
        o.release = 'alpha'
        o.version = '0.0.0'
        o.separator invitation(true) if actions?
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
