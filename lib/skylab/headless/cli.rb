module Skylab::Headless

  module CLI
    extend MetaHell::Autoloader::Autovivifying::Recursive

    OPT_RX = /\A-/                # ( yes this is actually used elsewhere :D )
  end

  module CLI::Action

    o = { }

    o[:summary_width] = -> op, max=0 do  # hack a peek into o.p to decide how
      max = CLI::FUN.summary_width[ op, max ] # wide to make column A
      max + op.summary_indent.length - 1  # (one space from o.p)
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze
  end

  module CLI::Action::ModuleMethods
    include Headless::Action::ModuleMethods

    def desc first, *rest         # [#hl-033] dsl-ly writer (and you have the
      ( @desc_lines ||= [ ] ).concat [ first, *rest ] # `desc_lines` reader
      nil                                             # defined in core::action
    end

    def option_parser &block      # dsl-ish that just accrues these for you.
      ( @option_parser_blocks ||= [ ] ).push block # turning it into an o.p.
      nil                         # is *your* responsibility. depends on what
    end                           # happens in your `build_option_parser` if any

    attr_reader :option_parser_blocks
  end

  module CLI::Action::InstanceMethods
    include Headless::Action::InstanceMethods

    def invoke argv
      @argv = argv ; arg = nil    # some callables care about @argv, some don't
      @queue ||= []               # essential here, must can be set elsewhere
      res = parse_opts @argv      # passed as arg so descendents can play dumb
      if true == res              # we check this a lot for [#hl-019], [#hl-023]
        @queue.push default_action if @queue.length.zero?
        begin                     # for each item on the queue, execute it but
          res, meth, args = normalize_callable @queue.first
          true == res or break
          res = meth.receiver.send meth.name, *args
          true == res or break
          @queue.shift            # now it is ok to say we processed it
        end while @queue.length.nonzero?
      end
      res
    end

  protected

    # (no initter method but ivars get set in `invoke`!)

    #                 ~ core controller-like methods ~

    def absorb_param_queue        # (see `param_queue` if you haven't)
      before = error_count        # (**NOTE** that by the time we get here,
      while @param_queue.length.nonzero? # we should be past the point of
        k, v = @param_queue.shift # validating whether it is a writable param
        send "#{ k }=", v         # because for now we just call send on it
      end                         # which for all we know could be some
      before < error_count        # random-ass private method)
    end

    def enqueue mixed_callable
      @queue.push mixed_callable
    end

    def exit_status_for sym       # [#hl-023] hook for exit statii if u want
    end

    def normalize_callable x
      if ::Array === x
        m = x.shift ; a = x       # (ick for now we mutate the queue element
        @queue[ 0 ] = m           # since we are processing it now and we need
      else                        # to store somewhere the name of the method
        m = x ; a = []            # used)
      end
      if ::Symbol === m
        normalize_callable_symbol m, a
      else
        opt = true ; req = false # are args allowed? are they mandatory?
        if m.respond_to? :receiver and m.respond_to? :name
          req = true
          method = m
        elsif m.respond_to? :call
          opt = false
          method = m.method :call
        else
          raise ::ArgumentError, "no - #{ m.class }"
        end
        if req
          a.length.zero? and raise ::ArgumentError, "(1 for 2) - #{ m.class }"
        elsif ! opt && a.length.nonzero?
          raise ::ArgumentError, "(#{ a.length } for 1) - #{ m.class }"
        end
        1 < a.length and raise ::ArgumentError, "#{ a.length } for 1..2"
        [ true, method, a.length.zero? ? [] : a.pop ]
      end
    end

    def normalize_callable_symbol sym, args
      cmp = 1 <=> args.length
      if -1 == cmp then raise ::ArgumentError, "#{ args.length } for 1..2" end
      if 0 == cmp                 # (args were provided internally to the item
        [ true, method( sym ), args.first ]  # that was on the queue.)
      else
        @upstream_is_collapsed ||= begin  # experimental one-time hook [#hl-022]
          @upstream_status = resolve_upstream  # clients can define this to get
          true                    # this hook called once, used in execution
        end                       # here as a prerequisite for below.
        if true == @upstream_status
          res = validate_arity_for sym, @argv
          if true == res
            [ true, method( sym ), @argv ]
          else
            [ res ]
          end
        else
          [ @upstream_status ]
        end
      end
    end

    # param_queue - a param queue is an experimental solution to the problem
    # of wanting to process options and arguments in an order-sensitive way,
    # (in the order they were received, for e.g.) and also wanting to separate
    # the parsing pass from the subsequent processing pass, i.e atomicly.
    #

    attr_reader :param_queue ; alias_method :param_queue_ivar, :param_queue

    def param_queue               # (experimental atomic processing of .e.g
      @param_queue ||= []         # options -- see warnings at
    end                           # `absorb_param_queue`)

    attr_reader :queue            # (internal use - this is for action graphs
                                  # that will use `argument_syntax` on objects
                                  # that haven't been invoked yet.)

    def resolve_upstream          # out of the box we make no assumtions about
      true                        # what your upstream should be, but per
    end                           # [#hl-023] this must be literally true for ok

    #   ~ core help-, string-, ui-msg-rendering methods and support ~

    # a "porcelain-visible" toplevel entrypoint method/action for help of
    # (non-box) actions!  (if you add a var name here it may appear in the
    # interface!) (just for fun we result in true instead of nil which may
    # have a strange effect..)

    def help
      @queue[ 0 ] = default_action  # always this is the action we show.
      help_screen help_yielder
      true
    end

    def help_description y # assume desc_lines is nonzero-length array
      y << ''                     # assumes there was content above!
      if 1 == desc_lines.length   # do the smart thing with formatting
        y << "#{ em 'description:' } #{ desc_lines.first }"
      else
        indent = option_parser ? option_parser.summary_indent : '  '
        y << "#{ em 'description:' }"
        desc_lines.each do |line|
          y << "#{ indent }#{ line }"
        end
      end
      nil
    end

    def help_options y     # precondition: an option_parser exists
      # (in the old days this was option_parser.to_s, which should still work.)
      y << ''                     # assumes there was previous above content!
      option_parser = option_documenter
      does_have_summary = option_parser.top.list.detect do |x|
        x.respond_to? :summarize
      end
      if does_have_summary
        y << "#{ em 'options:' }" # else maybe empty or doc only
      end
      option_parser.summarize do |line|
        y << line
      end
      nil
    end

    def help_screen y
      y << usage_line
      help_description y if desc_lines
      if option_documenter
        option_documenter.summary_width =
          CLI::Action::FUN.summary_width[ option_documenter ]
        help_options y
      end
      nil
    end

    def normalized_invocation_string  # since you are an action you can assume
      "#{ request_client.send :normalized_invocation_string }#{   # you have a
        } #{ name.to_slug }"                                          # parent
    end

    def help_yielder
      @help_yielder ||= ::Enumerator::Yielder.new { |l| emit :help, l }
    end

    def invite_line z=nil
      render_invite_line "#{ normalized_invocation_string } -h", z
    end                           # (this like so is used by cli-client too)

    def render_invite_line inner_string, z=nil
      "use #{ kbd inner_string } for help#{ " #{ z }" if z }"
    end

    strip_description_label_rx = /\A[ \t]*description:?[ \t]*/i  # hack below

    define_method :summary_line do
      if self.class.desc_lines
        super( )                  # 1) use first desc line if you have that
      elsif option_parser
        first = @option_parser.top.list.first
        if ::String === first     # 2) else use o.p banner if that
          str = CLI::Pen::FUN.unstylize[ first ]
          str.gsub strip_description_label_rx, '' # (#hack!)
        else
          CLI::Pen::FUN.unstylize[ usage_line ] # 3) else this, unstylized
        end
      end
    end

    # `usage_and_invite` - a mid-level entrypoint for this common form
    # of inteface screen of interface screen, called from `invoke` or
    # other actions that typically want to make a graceful "exit" with this
    # info. (it can be broken down further if needed..)
    # `msg` if provided gets its own leading first line. `z` if
    # provided gets appended to the end of the invite line.

    def usage_and_invite msg=nil, z=nil
      y = help_yielder
      y << msg if msg
      y << usage_line
      y << invite_line( z )
      nil
    end

    def usage_line
      a = [ em( 'usage:' ) ]      # (yes everything here does result in 1 line)
      a << normalized_invocation_string
      x = render_option_syntax                   ; a << x if x
      x = render_argument_syntax argument_syntax ; a << x if x
      a.compact.join ' '
    end

    #      ~ options - modeling, sub-control and rendering (mvvm) ~

    def option_documenter         # (a hook for descendents to override into,
      option_parser               # it will be called whenever something is
    end                           # being done that is expressly presentational)

    def option_is_visible_in_syntax_string
      @option_is_visible_in_syntax_string ||= ::Hash.new { |*| true }
    end

    # Out of the box we don't decide how to build your option_parser, you must
    # define `build_option_parser` (called below) yourself (even if have a
    # grammar that takes no options, just result in falseish, but you must
    # stil define a `b.o.p`, to keep things explicit.) (the DSL however is
    # a different story..)
    # Whatever if anything you result in from your `b.o.p`, if you result in a
    # true-ish it must follow a core interface for an o.p, one that is a tiny
    # subset of (and of course based off of) the public methods of stdlib's o.p:
    #
    #   + your o.p must provide a `parse!` that takes 1 array arg, like o.p
    #   + on parse failures your o.p must raise a stdlib o.p::ParseError
    #   + `top.list` must result in a switches enumberable
    #   + each switch must have a `long`, `short` and `arg` that look like o.p

    attr_reader :option_parser    # look:

    alias_method :option_parser_ivar, :option_parser

    def option_parser
      if option_parser_ivar.nil?  # (mutex-out subsequent calls to b.o.p
        @option_parser = build_option_parser || false  # unless user nillifies)
      end
      @option_parser
    end
                                  # mutate `argv` (which is probably also @argv)
    def parse_opts argv           # what you do with the data is your business.
      res = true                  # result in true on success, other on failure
      begin
        break if argv.length.zero? # don't even build option parser.
        break if is_branch && CLI::OPT_RX !~ argv.first # ambig. grammars [#024]
        break if ! option_parser  # leave brittany alone, downstream gets argv

        begin                     # option_parser can be some fancy arbitrary
          option_parser.parse! argv # thing, but it needs to conform to at
        rescue Headless::Services::OptionParser::ParseError => e # least
          usage_and_invite e.message  # these two parts of stdlib ::O_P
          res = exit_status_for :parse_opts_failed
        end
      end while nil
      if true == res && param_queue_ivar
        res = absorb_param_queue  # (here. see `param_queue`)
      end
      res
    end
                                  # nil when no o.p, nil when no visible opts
                                  # there is currently no unstyled form but..
    def render_option_syntax      # ..one could be made. also this does not
      if option_documenter        # currently style but one could be made.
        a = visible_options.reduce [] do |m, sw|
          m << "[#{ sw.short.first or sw.long.first }#{ sw.arg }]"
        end
        a.join ' ' if a.length.nonzero?
      end
    end
                                  # assume o.p complete, use hack, o.p compat
    def visible_options           # maybe zero length, kept flat & functiony
      ::Enumerator.new do |y|
        option_is_visible_in_syntax_string || nil # kick, ick
        option_documenter.top.list.each do |sw|
          if sw.respond_to?( :short ) &&
            @option_is_visible_in_syntax_string[ sw.object_id ] then
              y << sw
          end
        end
        nil
      end
    end

    #      ~ arguments - modeling, sub-control and rendering (mvvm) ~
    #

    def argument_syntax           # what a.s is "current" or "active"?
      sym = if queue && @queue.length.nonzero? && ::Symbol === @queue.first
        @queue.first  # (it looks wrong, but does it need fixing?)
      else
        default_action
      end
      argument_syntax_for_method sym
    end

    def argument_syntax_cache     # (right now little is lost and little is
      @argument_syntax_cache_h ||= { }  # gained by this but watch out near
    end                           # box / dsl)

    def argument_syntax_for_method method_ref
      argument_syntax_cache.fetch method_ref.intern do |meth_ref|
        @argument_syntax_cache_h[ meth_ref ] =
          Headless::CLI::Argument::Syntax::Inferred.new(
            method( meth_ref ).parameters, formal_parameters ) # nil ok, f.p
      end
    end

    def render_argument arg
      a, b = reqity_brackets arg.reqity
      "#{ a }<#{ arg.formal.name.to_slug }>#{ b }"
    end

    arg_string_h = {
      opt:  [ '[', ']'      ],
      req:  [ '',  ''       ],
      rest: [ '[', ' [..]]' ]
    }.each { |_, a| a.each(& :freeze).freeze }.freeze

    define_method :reqity_brackets do |reqity|
      arg_string_h.fetch reqity
    end

    # a #view-template-ish for rendering a particular argument syntax object
    # into a styled string. result is nil if the syntax has no elements,
    # otherwise a non-zero length, possibly styled string. With `em_range`
    # you can emphasize a contiguous subset of the elements. (there is
    # significance that this happens here and not in an auxiliary object)

    def render_argument_syntax syn, em_range=nil  # of the elements.
      a = syn.each.with_index.reduce [] do |m, (arg, idx)|
        s = render_argument arg
        if em_range and em_range.include? idx
          s = em s
        end
        m << s
      end
      a.join ' ' if a.length.nonzero?
    end
                                  # `meth_ref` is symbol or string method name
                                  # result is true or exit status
    def validate_arity_for meth_ref, args
      res = nil                   # assuming below is true, always re-assigned
      syn = argument_syntax_for_method meth_ref # (this will almost certainly raise on
      if syn                      # raise on failure, but it could change.)
        res = syn.validate_arity args do |o|
          o.on_unexpected do |a|
            usage_and_invite "unexpected argument#{ s a }: #{ ick a[0] }#{
              }#{" [..]" if a.length > 1 }"
            exit_status_for :argv_parse_failure_unexpected_arguments
          end
          o.on_missing do |fragment|
            a = fragment[ 0 .. fragment.index { |x| :req == x.reqity } ]
            usage_and_invite "expecting: #{ render_argument_syntax a, 0..0 }"
            exit_status_for :argv_parse_failure_missing_required_arguments
          end
        end
      end
      res
    end
  end

  class CLI::Argument   # might be joined by sister CLI::Option one day..
    # simple wrapper that combines ruby's builtin method.parameters `reqity`
    # with a formal parameter. (`reqity` is a term we straight made up to refer
    # to that property that is either :req, :opt or :rest, as seen in the
    # structure returned by ::Method#parameters.)

    attr_reader :formal

    def name
      @name ||= Headless::Name::Function.new @formal.normalized_local_name
    end

    attr_reader :reqity

    def initialize formal, reqity
      @formal, @reqity = formal, reqity
    end
  end

  class CLI::Argument::Syntax     # abstract

    # For error reporting it is useful to speak in terms of sub-slices of
    # argument syntaxes (used at least 2x here). (In fact, this was originally
    # a sub-class of ::Array (eek))  So some of that is mimiced here.

    [
      :each,   # used here in `render_argument_syntax`, from it we can have etc
      :first,  # for a.s inspection in cli/client
      :index,  # used here
      :length  # in cli/client
    ].each do |m|
      define_method m do |*a, &b|
        @elements.send m, *a, &b
      end
    end

    def slice ref
      if ::Range === ref
        new = self.class.allocate
        ba = base_args ; e = @elements
        new.instance_exec do
          base_init(* ba )
          @elements = e[ref]
        end
        new
      else
        @elements.fetch range
      end
    end

    alias_method :[], :slice

    # (we once had a `string` but it was a smell here - pls render it yrself)

  protected

    def initialize                # child classes must set @elements
    end

    alias_method :base_init, :initialize

    def base_args                 # compat with our `slice`. add parameters
      []                          # that you want to copy-by-reference to
    end                           # a nerk result of slice
  end

  class CLI::Argument::Syntax::Inferred < CLI::Argument::Syntax

    def validate_arity arg_a, &events  # result is true or hook result
      hooks = Headless::Parameter::Definer.new do
        param :on_missing, hook: true
        param :on_unexpected, hook: true
      end.new(& events )
      formal_idx = actual_idx = 0
      formal_end = @elements.length - 1
      actual_end = arg_a.length  - 1
      res = true  # important
      while actual_idx <= actual_end
        if formal_idx > formal_end
          res = hooks.on_unexpected[ arg_a[ actual_idx .. -1 ] ]
          break
        end
        if :rest == @elements[ formal_idx ].reqity
          formal_idx += 1
          break                   # (regardless of a, *b, c)
        end
        formal_idx += 1
        actual_idx += 1           # (regardless of opt / req)
      end
      idx = (formal_idx .. formal_end).detect do |i| # (bad range s/times)
        :req == @elements[i].reqity
      end
      if idx
        res = hooks.on_missing[ self[ idx .. -1 ] ]
      end
      res
    end

  protected

    def initialize ruby_param_a, formals
      @elements = ruby_param_a.reduce [] do |m, (opt_req_rest, name)|
        if formals
          fp = formals[ name ]
        end
        fp ||= Headless::Parameter.new nil, name
        m << CLI::Argument.new( fp, opt_req_rest )
      end
    end
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

    codes = ::Hash[ [[:strong, 1], [:reverse, 7]].
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

    def ick mixed                 # render an invalid value
      # stylize mixed.to_s.inspect, :strong, :dark_red  # may be overkill
      %|"#{ mixed }"|
    end

    def kbd s
      stylize s, :green
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
