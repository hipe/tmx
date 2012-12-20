module Skylab::Headless

  module CLI
    extend Autoloader

    OPT_RX = /\A-/                # ( yes this is actually used elsewhere :D )
  end


  module CLI::Action
    # pure namespace module, contained entirely this file
  end


  module CLI::Action::ModuleMethods
    include Headless::Action::ModuleMethods

    # def desc [#hl-033]

  end

  module CLI::Action::InstanceMethods
    extend MetaHell::Let

    include Headless::Action::InstanceMethods

    def invoke argv
      result = nil
      @argv = argv                # it really is nice to have it both ways, this
      @queue ||= []               # (omg cueue might have shenanigans on it)
      begin
        result = parse_opts argv  # implement parse_opt however you want,
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

    attr_accessor :param_h        # experimental, for dsl

  protected

    let :argument_syntax do       # assumes `default_action` for now
      build_argument_syntax_for default_action
    end

    attr_reader :argv

    def build_argument_syntax parameters_a
      Headless::CLI::ArgumentSyntax::Inferred.new parameters_a,
        pen, (formal_parameters if respond_to? :formal_parameters)
    end

    def build_argument_syntax_for method_name
      build_argument_syntax method( method_name ).parameters
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


    def help_options              # precondition: an option_parser exists
      # (in the old days this was option_parser.to_s, which should still work.)
      emit :help, ''              # assumes there was previous above content!
      if option_parser.top.list.detect { |x| x.respond_to? :summarize }
        emit :help, "#{ em 'options:' }"     # else maybe empty or doc only
      end
      option_parser.summarize do |line|
        emit :help, line
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
      if option_parser
        option_parser.summary_width = smart_summary_width[ option_parser ]
        help_options
      end
      nil
    end

    def invite_line # we have to avoid assuming we process opts
      "use #{ kbd "#{ request_runtime.send :normalized_invocation_string }#{
        } -h #{ normalized_local_action_name }" } for help"
    end

    def normalized_invocation_string
      "#{ @request_runtime.send :normalized_invocation_string } #{
        }#{ normalized_local_action_name }"
    end

    let :option_parser do
      self.build_option_parser
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

    def param_queue               # (experimental atomic processing of .e.g
      @param_queue ||= []         # options -- see manifesto and warnings at
    end                           # `process_param_queue!`)

    def parse_argv_for m
      as = build_argument_syntax_for m
      res = as.parse_argv( argv ) do |o|

        o.on_unexpected do |a|
          usage "unexpected argument#{ s a }: #{ a[0].inspect }#{
            }#{" [..]" if a.length > 1 }"
          nil
        end

        o.on_missing do |fragment|
          fragment = fragment[0..fragment.index{ |p| :req == p.opt_req_rest }]
          usage "expecting: #{ em fragment.string }"
          nil
        end

      end
      res
    end

    def parse_opts argv           # mutate `argv` (which is probably also @argv)
      @leaf ||= nil               # what you do with the data is your business.
      exit_status = true          # result in true on success, other on failure
      begin
        if argv.empty?            # options are always optional! don't even
          break                   # build option_parser, much less invoke it.
        end
        if branch?                # If we are a branch, how do we know whether
          if CLI::OPT_RX !~ argv.first    # to parse the opts?
            break
          end
        end # (might change [#hl-024])
        if ! option_parser        # if you don't have one, which is certainly
          break                   # not strange, then we just leave brittany
        end                       # alone and let downstream deal with argv
        begin                     # option_parser can be some fancy arbitrary
          option_parser.parse! argv # thing, but it needs to conform to at
        rescue Headless::Services::OptionParser::ParseError => e # least
          usage e.message         # these two parts of stdlib ::O_P
          exit_status = exit_status_for :parse_opts_failed
        end
      end while nil
      @param_queue ||= nil        # #experimental'y get through basic option
      if true == exit_status && @param_queue # parsing first before you
        exit_status = process_param_queue! # before you actually validate
      end                         # with your custom setters (if u want)
      exit_status
    end

    def process_param_queue!      # see how this is uses to see how this is
      res = true                  # used (sorry!) very experimental.
      before = error_count        # **NOTE** that by the time it gets on the
      loop do                     # param queue, it should be past the point
        k, v = param_queue.shift  # of validating whether it is a writable
        k or break                # parameters because for now we just call
        send "#{ k }=", v         # send on it which for all we know could
      end                         # be some private-ass method.
      if before < error_count
        res = false
      end
      res
    end

    attr_reader :queue

    def resolve_upstream          # out of the box we make no assumtions about
      true                        # what your upstream should be, but per
    end                           # [#hl-023] this must be literally true for ok


    strip_description_label_rx = /\A[ \t]*description:?[ \t]*/i

    define_method :summary_line do
      res = nil
      begin
        if self.class.desc_lines               # 1) if we have desc lines
          break( res = super )                 # then use the first one (prolly)
        end
        op = option_parser                     # 2) else if we have an o.p.
        if op                                  # *and* the first element of it
          first = op.top.list.first            # is a string, use that! #exp
          if ::String === op.top.list.first
            str = CLI::Pen::FUN.unstylize[ first ]
            res = str.gsub strip_description_label_rx, '' # (#hack!)
            break
          end
        end
        res = CLI::Pen::FUN.unstylize[ usage_line ] # 3) else this, unstylized
      end while nil
      res
    end

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
        argument_syntax.string
      ].compact.join ' '
    end
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
          result = hooks.on_unexpected[ actual ]
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
        result = hooks.on_missing[ formal ]
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


  module CLI::IO_Adapter
    # pure namespace, all in this file.
  end


  class CLI::IO_Adapter::Minimal <            # For now (near [#sl-113] we do
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
    def initialize sin, sout, serr, pen=CLI::Pen::MINIMAL
      super sin, sout, serr, pen
    end
  end


  module CLI::Pen                              # (see manifesto at H_L::Pen)

    o = { }

    codes = ::Hash[ [[:strong, 1]].
      concat [:dark_red, :green, :yellow, :blue, :purple, :cyan, :white, :red].
        each.with_index.map { |v, i| [v, i+31] } ]

    o[:code_names] = codes.keys                # a couple subproducts use these

    o[:stylize] = -> str, *styles do
      "\e[#{ styles.map { |s| codes[s] }.compact.join ';' }m#{ str }\e[0m"
    end

    o[:unstylize_stylized] = unstylize_stylized = -> str do # nil when `str` is
      str.to_s.dup.gsub! %r{  \e  \[  \d+  (?: ; \d+ )*  m  }x, '' # not already
    end                                        # stylized - rec. only for tests!

    o[:unstylize] = -> str do                  # the safer alternative, for when
      unstylize_stylized[ str ] || str         # you don't care whether it was
    end                                        # stylzed in the first place

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze

  end


  module CLI::Stylize
    # pure namespace contained in this file.
  end


  module CLI::Stylize::Methods                 # here we have what amounts to
                                               # i.m version of low level funcs,
    fun = CLI::Pen::FUN                        # if you need e.g. `stylize`
                                               # or `unstylize` and you don't
    define_method :stylize, & fun.stylize      # want to pollute your namespace
                                               # or coupling with all the
    define_method :unstylize, & fun.unstylize  # view-y style names of Pen::I_M
                                               # However avoid calling `stylize`
    define_method :unstylize_stylized, &fun.unstylize_stylized # in application
                                               # code when you can instead use
    (fun.code_names - [:strong]).each do |c|   # (away at [#pl-013]) existing,
      define_method( c ) { |s| stylize(s, c) } # modality-portable styles!
      define_method(c.to_s.upcase) { |s| stylize(s, :strong, c) }
    end
  end


  module CLI::Pen::InstanceMethods
    include Headless::Pen::InstanceMethods
                        # (trying to use these when appropriate:
                        # http://www.w3schools.com/tags/tag_phrase_elements.asp)

    def em s
      stylize s, :strong, :green
    end

    def invalid_value mixed
      stylize(mixed.to_s.inspect, :strong, :dark_red) # may be overkill
    end

    def kbd s
      stylize s, :green
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

    fun = CLI::Pen::FUN

    define_method :stylize, & fun.stylize      # yes i repeat these same calls
                                               # above -- it's because i hate
    define_method :unstylize, & fun.unstylize  # absurdly long ancestor chains
                                               # more than i hate a little
    define_method :unstylize_stylized, & fun.unstylize_stylized # redundancy
                                               # in declarative metaprogramming.
  end


  class CLI::Pen::Minimal
    include CLI::Pen::InstanceMethods
  end

  CLI::Pen::MINIMAL = CLI::Pen::Minimal.new

end
