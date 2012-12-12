module Skylab::Headless

  module CLI
    extend Autoloader

    OPT_RX = /\A-/                # ( yes this is actually used elsewhere :D )
  end


  module CLI::Action
  end


  module CLI::Action::InstanceMethods
    extend MetaHell::Let

    include Headless::Action::InstanceMethods

    def invoke argv
      @argv = argv                # it really is nice to have it both ways, this
      (@queue ||= []).clear       # create queue if not exist, and empty it
      result = nil                # (#todo we might be insane and not empty it)
      begin
        result = parse_opts argv  # implement parse_opts however you want,
        true == result or break   # but to allow fancy exit statii we have to
                                  # observe this strict ickiness [#hl-023]

        if queue.empty?           # during parse_opts client may have added
          enqueue! default_action # action items to the queue. As name suggests,
        end                       # this is the default case that they didn't.

        upstream_resolved = false # (experimental, do this at most once)
        while ! queue.empty?      # effectively for each item on the queue:
          x = queue.first         # peek ahead before shifting
          if ! x                  # clients may add a falseish to the queue
                                  # during parse_opts to indicate they did
                                  # something, hence don't use default_action
          elsif x.respond_to? :call # this is typically a lambda added during
            result = x.call       # parse_opts but it could be anything.
            true == result or break # again with [#hl-023] for now, exit codes

          else
            if ! upstream_resolved # experimentally once evar in this shebang we
              result = resolve_upstream # give the client a chance to impl.
              true == result or break # custom upstream resolution [#hl-022]
              upstream_resolved = true # observing the now familiar chance to
            end                   # set exit code on failure [#hl-023]

            a = parse_argv_for x  # We assume now that actionable x is a method
            if ! a                # but if that failed, short circuit out of
              result = exit_status_for :parse_argv_failed # processing the rest
              break               # of the queue
            end
            result = send( x, *a ) #                 money
            true == result or break # for now [#hl-023] we assume you gave us
            result or break       # an exit code and we should stop unless
          end                     # result was exactly true.
          queue.shift             # shift queue only when succeeded with that
        end                       # actionable item.
      end while nil
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

    def parse_opts argv           # mutate `argv` (which is probably also @argv)
                                  # what you do with the data is your business.
      exit_status = true          # result in true on success, other on failure
      begin
        if argv.empty?            # options are always optional! don't even
          break                   # build any option_parser, much less invoke it
        end
        if CLI::OPT_RX !~ argv.first # avoid parsing opts intended for child
          break                   # actions by requiring that opts come before
        end                       # args (might change [#hl-024])
        if ! option_parser        # if you don't have one, which is certainly
          break                   # not strange, then we just leave brittany
        end                       # alone and let downstream deal with argv
        begin                     # option_parser can be some fancy arbitrary
          option_parser.parse! argv # thing, but it needs to conform to at least
        rescue ::OptionParser::ParseError => e # these two parts of stdlib ::O_P
          usage e.message
          exit_status = exit_status_for :parse_opts_failed
        end
      end while nil
      exit_status
    end

    attr_reader :queue

    def resolve_upstream          # out of the box we make no assumtions about
      true                        # what your upstream should be, but per
    end                           # [#hl-023] this must be literally true for ok

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


    def build_io_adapter sin=$stdin, sout=$stdout, serr=$stderr, pen=build_pen
      # What is really nice is if you observe [#sl-114] and specify what
      # actual streams you want to use for these formal streams.  However
      # we grant ourself this one indulgence of specifying these most
      # conventional of defaults here, provided that this is the only place
      # library-wide that we will see a mention of these globals.

      io_adapter_class.new sin, sout, serr, pen
    end

    def infile_noun               # a bit of a hack to go with resolve_instream
      name = nil
      begin
        if ! queue.empty?
          as = build_argument_syntax_for queue.first
          if ! as.empty?
            name = as.first.name
            break
          end
        end
        name = 'infile' # sketchy..
      end while nil
      parameter_label name
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


    def resolve_instream # (the probable destination of [#hl-022], in flux)

      # #experimental: Figure out which of several possible datasources should
      # be the stream for reading from based on whether the instream (stdin) is
      # a tty (interactive terminal) or not, and whether arguments exist in
      # argv, and if so, whether the number of those argv arguments is one, and
      # if so, if it is a filename that can be read (whew!)
      #
      # If it gets to this last case, (**NOTE**) it will mutate argv by shifting
      # this one arg off of it, it will open this filehandle (!!),
      # **and** reassign io_adapter.instream with this handle, possibly
      # releasing the original handle!! (For now, manifestations of this are
      # tracked org-wide with the tag #open-filehandle-1)
      #
      # This is an #experimental attempt to generalize this stuff, but is
      # probably premature in its current state, hence [#hl-022] will be
      # expected to be active for a while.
      #
      # The confusingly similarly named `resolve_upstream` is the same idea,
      # but we let that be a stub function that clients can opt-in to,
      # possibly implementing it simply by calling this.

      res = false                 # must be true on success per [#hl-023]
                                  # (imagine that false signifies a request
                                  # to display usage, invite after the error(s))
                                  # it is the default value b/c so common!

      try_instream = -> do
        res = true                # nothing to to.
      end

      ambiguous = -> do
        error "cannot resolve ambiguous instream modality paradigms --#{
          } both STDIN and #{ infile_noun } appear to be present."
      end

      try_argv = -> do
        case argv.length
        when 0
          if suppress_normal_output
            info "No #{ infile_noun } argument present. Done."
            io_adapter.instream = nil # ok sure why not
            res = nil
          else
            error "expecting: #{ infile_noun }"
          end
        when 1
          o = ::Pathname.new argv.shift
          if o.exist?
            if o.directory?
              error "#{ infile_noun } is directory: #{ o }"
            else
              io_adapter.instream = o.open 'r'
              # (the above is #open-filehandle-1 --  don't loose track!)
              res = true
            end
          else
            error "#{ infile_noun } not found: #{ o }"
          end
        else
          error "expecting: #{ infile_noun } had: (#{ argv.join ' ' })"
        end
      end

      argv = self.argv.empty?         ? :argv_empty  : :some_argv
      term = io_adapter.instream.tty? ? :interactive : :noninteractive

      case [term, argv]
      when [:interactive,    :argv_empty] ; try_argv[ ]
      when [:interactive,    :some_argv]  ; try_argv[ ]
      when [:noninteractive, :argv_empty] ; try_instream[ ]
      when [:noninteractive, :some_argv]  ; ambiguous[ ]
      end

      res
    end

    def suppress_normal_output!   # #experimental hack to let e.g. officious
      @suppress_normal_output = true # actions indicate that they executed, and
      self                        # if given a a choice there is no need to do
    end                           # further processing.

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


  class CLI::IO::Adapter::Minimal <            # For now (near [#sl-113] we do
    ::Struct.new :instream, :outstream, :errstream, :pen # not observe the PIE
    # convention, which is a higher-level eventy thing that assumes semantic
    # meaning to the different streams. Down here, we just want symbolic names
    # that represent the actual streams (whatever they are) that are used in the
    # POSIX standard way of having a standard in, standard out, and standard
    # error stream.


    def emit type, msg            # life is easy with this default assumption
      send( :payload == type ? :outstream : :errstream ).puts msg
      nil # undefined
    end


    # per edict [#sl-114] keep explicit mentions of the streams out at this
    # level -- they can be nightmarish to adapt otherwise.
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

    def parameter_label x, idx=nil
      if ::Symbol === x
        str = x.to_s
      else
        str = x.name.to_s
      end
      stem = str.gsub '_', '-'
      idx = "[#{ idx }]" if idx
      "<#{ stem }#{ idx }>" # will get built out eventually
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
