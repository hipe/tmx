module Skylab::Headless
  module CLI end
  module CLI::InstanceMethods
    include Headless::Client::InstanceMethods
    def invoke argv
      @argv = argv
      (@queue ||= []).clear
      begin
        option_parser.parse! argv
      rescue ::OptionParser::ParseError => e
        usage e.message
        return exit_status_for(:parse_opts_failed)
      end
      queue.empty? and enqueue! default_action
      result = nil
      until queue.empty?
        if m = queue.first # implementations may use (meaningful) empty opcodes
          if m.respond_to?(:call)
            result = m.call or break
          elsif a = parse_argv_for(m)
            result = send(m, *a) or break
          else
            result = exit_status_for(:parse_argv_failed)
            break
          end
        end
        queue.shift
      end
      result
    end
  protected
    attr_reader :argv
    def argument_syntax_for m
      @argument_syntax = # ''hazy''
      (@argument_syntaxes ||= {})[m] ||= build_argument_syntax_for(m)
    end
    def argument_syntax_string
      (@argument_syntax ||= nil) or argument_syntax_for(default_action)
      @argument_syntax.string # ''hazy''
    end
    def build_argument_syntax_for m
      Headless::CLI::ArgumentSyntax::Inferred.new(pen, method(m).parameters,
        respond_to?(:formal_paramaters) ? formal_parameters : nil)
    end
    def build_io_adapter
      io_adapter_class.new $stdin, $stdout, $stderr, build_pen
    end
    def build_pen
      pen_class.new
    end
    def enqueue! method
      queue.push method
    end
    def exit_status_for sym
    end
    def help_string
      option_parser.to_s
    end
    def help
      emit(:help, help_string)
      true
    end
    def in_file
      "#{pen.parameter_label argument_syntax_for(queue.first).first}"
    end
    def invite
      emit(:help, "use #{em "#{program_name} -h"} for more help")
    end
    def io_adapter_class
      Headless::CLI::IO::Adapter::Minimal
    end
    def option_parser
      @option_parser ||= build_option_parser
    end
    def option_syntax_string
      (@option_parser ||= nil) or return nil
      @option_parser.top.list.map do |s|
        "[#{s.short.first or s.long.first}#{s.arg}]" if s.respond_to?(:short)
      end.compact.join(' ') # stolen and improved from Bleeding @todo
    end
    def parse_argv_for m
      argument_syntax_for(m).parse_argv(argv) do |o|
        o.on_unexpected do |a|
          usage("unexpected argument#{s a}: #{a[0].inspect}#{
            " [..]" if a.length > 1}") && nil
        end
        o.on_missing do |fragment|
          fragment = fragment[0..fragment.index{ |p| :req == p.opt_req_rest }]
          usage("expecting: #{em fragment.string}") && nil
        end
      end
    end
    def pen_class ; CLI::IO::Pen::Minimal end
    def program_name
      (@program_name ||= nil) || ::File.basename($PROGRAM_NAME)
    end
    attr_writer :program_name
    attr_reader :queue
    # its location here is experimental. note it may open a filehandle.
    def resolve_instream
      stdin = io_adapter.instream.tty? ? :tty : :stdin
      no_argv = argv.empty? ? :no_argv : :argv
      opcode =
      case [stdin, no_argv]
      when [:tty, :argv], [:tty, :no_argv] ; :argv
      when [:stdin, :argv]                 ; :ambiguous
      when [:stdin, :no_argv]              ; :stdin
      end
      result = nil
      case opcode
      when :ambiguous
        usage("cannot resolve ambiguous instream modality paradigms -- " <<
          "both STDIN and #{in_file} appear to be present.")
      when :stdin ; result = io_adapter.instream
      when :argv
        in_path = nil
        case argv.length
        when 0 ; suppress_normal_output? ?
                   info("No #{in_file} argument present. Done.") :
                   usage("expecting: #{in_file}")
        when 1 ; in_path = argv.shift
        else   ; usage("expecting: #{in_file} had: (#{argv.join(' ')})")
        end
        in_path and begin
          in_path = ::Pathname.new(in_path)
          if ! in_path.exist? then usage("#{in_file} not found: #{in_path}")
          elsif in_path.directory? then usage("#{in_file} is dir: #{in_path}")
          else result = io_adapter.instream = in_path.open('r') # ''spot 1''
          end
        end
      end
      result
    end
    def suppress_normal_output!
      @suppress_normal_output = true
      self
    end
    attr_reader :suppress_normal_output
    alias_method :suppress_normal_output?, :suppress_normal_output
    def usage msg=nil
      emit(:usage, msg) if msg
      emit(:usage, usage_line)
      invite
      nil # return value undefined, but client might override and do otherwise
    end
    def usage_line
      "#{em('usage:')} #{usage_syntax_string}"
    end
    def usage_syntax_string
      [program_name, option_syntax_string, argument_syntax_string].compact * ' '
    end
  end

  module CLI::ArgumentSyntax end
  module CLI::ArgumentSyntax::ParameterInstanceMethods
    attr_accessor :opt_req_rest
  end

  class CLI::ArgumentSyntax::Inferred < ::Array
    def initialize pen, method_parameters, formal_parameters
      @pen = pen
      formal_parameters ||= {}
      formal_method_parameters = method_parameters.map do |opt_req_rest, name|
        p = formal_parameters[name] ||
          Headless::Parameter::Definition.new(nil, name)
        p.extend Headless::CLI::ArgumentSyntax::ParameterInstanceMethods
        p.opt_req_rest = opt_req_rest # mutates the parameter!
        p
      end
      concat formal_method_parameters
    end
    def [](*a) ; super._dupe!(self) end
    def parse_argv argv, &events
      hooks = Headless::Parameter::Definer.new do
        param :on_missing, hook: true
        param :on_unexpected, hook: true
      end.new(&events)
      formal = dup
      actual = argv.dup
      result = argv
      while ! actual.empty?
        if formal.empty?
          result = hooks.on_unexpected.call(actual)
          break
        elsif idx = formal.index { |f| :req == f.opt_req_rest }
          actual.shift # knock these off l to r always
          formal[idx] = nil # knock the leftmost required off
          formal.compact!
        elsif :rest == formal.first.opt_req_rest
          break
        elsif # assume first is :opt and no required exist
          formal.shift
          actual.shift
        end
      end
      if formal.detect { |p| :req == p.opt_req_rest }
        result = hooks.on_missing.call(formal)
      end
      result
    end
    def string
      map do |p|
        case p.opt_req_rest
        when :opt  ; "[#{ pen.parameter_label p }]"
        when :req  ; "#{ pen.parameter_label p }"
        when :rest ; "[#{ pen.parameter_label p } [..]]"
        end
      end.join(' ')
    end
  # -- * --
    def _dupe! other
      @pen = other.pen
      self
    end
  protected
    attr_reader :pen
  end

  module CLI::IO end
  module CLI::IO::Adapter end
  class CLI::IO::Adapter::Minimal <
    ::Struct.new(:instream, :outstream, :errstream, :pen)
    def emit type, msg
      send( :payload == type ? :outstream : :errstream ).puts msg
      nil # undefined
    end
  end

  module CLI::IO::Pen end
  module CLI::IO::Pen::InstanceMethods
    include Headless::IO::Pen::InstanceMethods
    MAP = ::Hash[ [[:strong, 1]].
      concat [:dark_red, :green, :yellow, :blue, :purple, :cyan, :white, :red].
        each.with_index.map { |v, i| [v, i+31] } ]
    def invalid_value mixed
      stylize(mixed.to_s.inspect, :strong, :dark_red) # may be overkill
    end
    def parameter_label m, idx=nil
      stem = (::Symbol === m ? m.to_s : m.name.to_s).gsub('_', '-')
      idx and idx = "[#{idx}]"
      "<#{stem}#{idx}>" # will get build out eventually
    end
    def stylize str, *styles
      "\e[#{styles.map{ |s| MAP[s] }.compact.join(';')}m#{str}\e[0m"
    end
    def unstylize str # nil if string is not stylized
      str.dup.gsub!(/\e\[\d+(?:;\d+)*m/, '')
    end
  end

  class CLI::IO::Pen::Minimal
    include CLI::IO::Pen::InstanceMethods
    def em s ; stylize(s, :strong, :green) end
  end
  CLI::IO::Pen::MINIMAL = CLI::IO::Pen::Minimal.new
end
