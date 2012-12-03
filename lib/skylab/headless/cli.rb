module Skylab::Headless

  module CLI
    extend Autoloader

    OPT_RX = /\A-/
  end


  module CLI::Action
  end


  module CLI::Action::InstanceMethods
    extend MetaHell::Let

    include Headless::Action::InstanceMethods

    def invoke argv
      @argv = argv
      (@queue ||= []).clear
      if option_parser and CLI::OPT_RX =~ argv.first # maybe sub-action want it
        begin
          option_parser.parse! argv
        rescue ::OptionParser::ParseError => e
          usage e.message
          return exit_status_for :parse_opts_failed
        end
      end
      queue.empty? and enqueue! default_action
      result = nil
      until queue.empty?
        if m = queue.first # implementations may use (meaningful) empty opcodes
          if m.respond_to? :call
            result = m.call or break
          elsif a = parse_argv_for( m )
            result = send( m, *a ) or break
          else
            result = exit_status_for :parse_argv_failed
            break
          end
        end
        queue.shift
      end
      result
    end

  protected

    let :argument_syntax do          # assumes `default_action` for now
      build_argument_syntax_for default_action
    end

    attr_reader :argv

    def build_argument_syntax_for method_name
      Headless::CLI::ArgumentSyntax::Inferred.new(
        method( method_name ).parameters,
        pen,
        (formal_parameters if respond_to? :formal_parameters) )
    end

    def enqueue! mixed_callable
      queue.push mixed_callable
    end

    def exit_status_for sym
                                  # descendants may want to do something fancy
    end

    def help
      help_screen                 # just for fun we return trueish so that we
      true                        # do any further processing in the queue.
    end

    def help_options              # in the old days this was option_parser.to_s
      if option_parser
        emit :help, ''            # assumes there was previous above content!
        if option_parser.top.list.detect { |x| x.respond_to? :summarize }
          emit :help, "#{ em 'options:' }"     # else maybe empty or doc only
        end
        option_parser.summarize do |line|
          emit :help, line
        end
      end
    end

    smart_summary_width = -> option_parser do
      max = CLI::FUN.summary_width[ option_parser ]
      # Make the indent of the second column be the same as the first.
      # (Out of the box we get one space, hence the minus one.)
      max + option_parser.summary_indent.length - 1
    end

    define_method :help_screen do
      emit :help, usage_line
      option_parser.summary_width = smart_summary_width[ option_parser ]
      help_options
      nil
    end

    def invite_line # we have to avoid assuming we process opts
      "use #{ kbd "#{ request_runtime.send :normalized_invocation_string
        } -h #{ normalized_local_action_name }" } for help"
    end

    def normalized_invocation_string
      "#{ @request_runtime.send :normalized_invocation_string } #{
        normalized_local_action_name}"
    end

    let :option_parser do
      build_option_parser
    end

    def option_syntax_string
      if option_parser
        option_parser.top.list.map do |s|
          if s.respond_to? :short
            "[#{s.short.first or s.long.first}#{s.arg}]"
          end
        end.compact.join ' ' # stolen and improved from Bleeding #todo
      end
    end

    def parse_argv_for m
      build_argument_syntax_for(m).parse_argv(argv) do |o|
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

    attr_reader :queue

    def usage msg=nil
      emit :help, msg if msg
      usage_and_invite
      nil # return value undefined, but client might override and do otherwise
    end

    def usage_and_invite
      emit :help, usage_line
      emit :help, invite_line
      nil
    end

    def usage_line
      "#{ em('usage:') } #{ usage_syntax_string }"
    end

    def usage_syntax_string
      [ normalized_invocation_string,
        option_syntax_string,
        argument_syntax.string ].compact.join ' '
    end
  end


  module CLI::Client
  end


  module CLI::Client::InstanceMethods
    include CLI::Action::InstanceMethods
    include Headless::Client::InstanceMethods

  protected

    def build_io_adapter
      io_adapter_class.new $stdin, $stdout, $stderr, build_pen
    end

    def in_file
      "#{ parameter_label build_argument_syntax_for(queue.first).first }"
    end

    def invite_line
      "use #{ kbd "#{ normalized_invocation_string } -h" } for help"
    end

    def normalized_invocation_string
      program_name
    end

    def io_adapter_class
      Headless::CLI::IO::Adapter::Minimal
    end

    def info msg                  # barebones implementation as a convenience
      emit :info, msg             # for this shorthand commonly used in
      nil                         # debugging and verbose modes
    end

    def pen_class
      CLI::IO::Pen::Minimal
    end

    def program_name
      (@program_name ||= nil) or ::File.basename $PROGRAM_NAME
    end

    attr_writer :program_name

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
        usage "cannot resolve ambiguous instream modality paradigms --#{
          } both STDIN and #{ in_file } appear to be present."
      when :stdin ; result = io_adapter.instream
      when :argv
        in_path = nil
        case argv.length
        when 0 ; suppress_normal_output ?
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

  end


  module CLI::ArgumentSyntax
  end


  module CLI::ArgumentSyntax::ParameterInstanceMethods
    attr_accessor :opt_req_rest
  end


  class CLI::ArgumentSyntax::Inferred < ::Array

    def [] *a
      super._dupe! self
    end

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
        when :opt  ; "[#{ parameter_label p }]"
        when :req  ; "#{ parameter_label p }"
        when :rest ; "[#{ parameter_label p } [..]]"
        end
      end.join(' ')
    end

  # -- * --

    def _dupe! other
      @pen = other.pen
      self
    end

  protected

    def initialize method_parameters, pen, formal_parameters
      @pen = pen
      formal_parameters ||= {}
      formal_method_parameters = method_parameters.map do |opt_req_rest, name|
        p = formal_parameters[name] ||
          Headless::Parameter::Definition.new( nil, name )
        p.extend Headless::CLI::ArgumentSyntax::ParameterInstanceMethods
        p.opt_req_rest = opt_req_rest # mutates the parameter!
        p
      end
      concat formal_method_parameters
    end

    def parameter_label *a
      pen.parameter_label(* a) # etc
    end

    attr_reader :pen

  end


  module CLI::IO
  end


  module CLI::IO::Adapter
  end


  class CLI::IO::Adapter::Minimal <
    ::Struct.new :instream, :outstream, :errstream, :pen

    def emit type, msg
      send( :payload == type ? :outstream : :errstream ).puts msg
      nil # undefined
    end

                                  # per [#sl-114] you're not gonna get it
                                  # as easy as you would might like
    def initialize sin, sout, serr, pen=CLI::IO::Pen::MINIMAL
      super sin, sout, serr, pen
    end
  end


  module CLI::IO::Pen

    o = { }

    o[:unstylize] = -> str do # nil if string is not stylized
      str.dup.gsub! %r{  \e  \[  \d+  (?: ; \d+ )*  m  }x, ''
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v }

  end


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

    define_method :unstylize, & CLI::IO::Pen::FUN.unstylize

  end


  class CLI::IO::Pen::Minimal
    include CLI::IO::Pen::InstanceMethods

    def em s
      stylize s, :strong, :green
    end

    def kbd s
      stylize s, :green
    end

    # http://www.w3schools.com/tags/tag_phrase_elements.asp
  end

  CLI::IO::Pen::MINIMAL = CLI::IO::Pen::Minimal.new

end
