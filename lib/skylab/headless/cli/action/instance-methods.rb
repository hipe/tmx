module Skylab::Headless

  module CLI::Action::InstanceMethods

    include Headless::Action::InstanceMethods

    def invoke argv
      @argv = argv                # some callables care about @argv, some don't
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

  private

    define_singleton_method :private_attr_reader, & Private_attr_reader_

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
  end
  module CLI
    module Action
      module InstanceMethods
        def say * a, &p  # #storypoint-18 (pinned to first occurrence of 'say')
          if p
            expression_agent.calculate( * a, & p )
          else
            say_w_lxcn( * a )
          end
        end

        def expression_agent
          pen
        end

        def say_w_lxcn i
          lxcn.fetch_default i
        end

        def lxcn  # stub implementation
          LEXICON__  # defined near at first write
        end

        Action::LEXICON__ = (( class Action::Lexicon__
          def initialize
            @bx = Headless::Services::Basic::Box.new ; nil
          end
          def fetch_default i, &p
            @bx.fetch i, &p
          end
          def add_entry_with_default i, s
            @bx.add i, s.freeze ; nil
          end
          self
        end )).new

        def format_header header_s
          "#{ header_s }:"
        end
      end
    end
  end

  module CLI::Action::InstanceMethods

    # param_queue - a param queue is an experimental solution to the problem
    # of wanting to process options and arguments in an order-sensitive way,
    # (in the order they were received, for e.g.) and also wanting to separate
    # the parsing pass from the subsequent processing pass, i.e atomicly.
    #

    private_attr_reader :param_queue
    alias_method :param_queue_ivar, :param_queue

    def param_queue               # (experimental atomic processing of .e.g
      @param_queue ||= []         # options -- see warnings at
    end                           # `absorb_param_queue`)

    private_attr_reader :queue    # (internal use - this is for action graphs
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

    def help_screen y                          # (pre-order for the big ones)
      render_usage_lines_to y
      help_description y if desc_lines
      # (Find the narrowest we can make column A of all sections (including
      # any options) such that we accomodate the widest content there!)
      max_width = if ! @sections then 0 else
        @sections.reduce 0 do |memo, sect|
          if sect.lines.length.nonzero?
            memo = sect.lines.reduce memo do |m, row|
              ( row[1] && row[1].length > m ) ? row[1].length : m
            end
          end
          memo
        end
      end
      if option_documenter
        w = CLI::Action::FUN.summary_width[ option_documenter, max_width ]
        option_documenter.summary_width = w
        help_options y
      end
      help_sections y, max_width if @sections
      nil
    end
    protected :help_screen  # #protected-not-private

    def help_description y # assume desc_lines is nonzero-length array
      y << ''                     # assumes there was content above!
      if 1 == desc_lines.length   # do the smart thing with formatting
        y << "#{ em 'description:' } #{ desc_lines.first }"
      else
        indent = option_documenter ? option_documenter.summary_indent : '  '
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
      does_have_summary = option_parser.top.list.detect do |x|  # #[059] base?
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

    def help_sections y, max_width
      od = option_documenter
      if od
        ind, sw = od.summary_indent, ( od.summary_width + 1 )  # dunno
      else
        ind, sw = '  ', max_width
      end
      fmt = "%-#{ sw }s"
      h = {
        line: -> x { y << x[1] },
        item:  -> x do
          if x[1]
            if x[2]
              y << "#{ ind }#{ h2( fmt % x[1] ) }#{ x[2] }"
            else
              y << "#{ ind }#{ h2 x[1] }"
            end
          else
            y << "#{ ind }#{ fmt % '' }#{ x[2] }"
          end
        end
      }
      @sections.each do |section|
        y << ''                     # we've been assuming there is content above
        y << "#{ hdr section.header }" if section.header
        section.lines.each do |line|
          h.fetch( line[0] )[ line ]
        end
      end
      nil
    end

    #                ~~ (assorted help support) ~~

    def normalized_invocation_string  # since you are an action you can assume
      "#{ request_client.send :normalized_invocation_string }#{   # you have a
        } #{ name.as_slug }"                                          # parent
    end

    def help_yielder
      @help_yielder ||= ::Enumerator::Yielder.new { |l| emit :help, l }
    end

    def invite_line z=nil
      render_invite_line "#{ normalized_invocation_string } -h", z
    end ; public :invite_line

    def render_invite_line inner_string, z=nil
      "use #{ kbd inner_string } for help#{ " #{ z }" if z }"
    end

    -> do  # `summary_line`

      strip_description_label_rx = /\A[ \t]*description:?[ \t]*/i

      define_method :summary_line do
        if desc_lines
          @desc_lines.first         # 1) use first desc line if you have that
        elsif option_parser
          first = @option_parser.top.list.first  # NOTE not base()
          if ::String === first     # 2) else use o.p banner if that
            str = CLI::Pen::FUN.unstyle[ first ]
            str.gsub strip_description_label_rx, '' # (#hack!)
          else
            CLI::Pen::FUN.unstyle[ usage_line ] # 3) else this, unstyled
          end
        end
      end
    end.call

    # `usage_and_invite` - a mid-level entrypoint for this common form
    # of inteface screen of interface screen, called from `invoke` or
    # other actions that typically want to make a graceful "exit" with this
    # info. (it can be broken down further if needed..)
    # `msg` if provided gets its own leading first line. `z` if
    # provided gets appended to the end of the invite line.

    def usage_and_invite msg=nil, z=nil
      y = help_yielder
      y << msg if msg
      render_usage_lines_to y
      y << invite_line( z )
      nil
    end

    def render_usage_lines_to y
      y << usage_line ; nil
    end

    def usage_line
      a = [ em( 'usage:' ) ]      # (yes everything here does result in 1 line)
      a << normalized_invocation_string
      x = render_option_syntax ; x and a << x
      x = render_argument_syntax_term ; x and a << x
      a.compact.join ' '
    end

    def render_argument_syntax_term
      render_argument_syntax argument_syntax
    end

    #         ~ the `desc_lines` facility ~

    #  + there is a corsponding opt-in m.m side to this i.m side [#hl-033]
    #  + @desc_lines (the ivar) is cached because of how it is used but if that
    #    is ever a problem just nillify it
    #  + @desc_lines (once it is collapsed) is meant to be always either
    #    false or a non-zero-length array. This makes implementation easier
    #    in several places.
    #  + This implementation must not and should not be married tightly to
    #    the module methods -- they should be opt-in.

    private_attr_reader :desc_lines  # watch:

    alias_method :desc_lines_ivar, :desc_lines

    def desc_lines                # it is cached because of how it is used but
      if desc_lines_ivar.nil?     # you can nillify the ivar as necessary or
        @desc_lines = build_desc_lines || false  # even override this whole
      else                        # shebang.
        @desc_lines
      end
    end

    def build_desc_lines          # this is where @sections is set too!
      @sections = false           # just to be safe
      lines = raw_desc_lines
      if lines
        sections = parse_sections lines
        if sections.length.nonzero?
          if ! sections[0].header
            res = sections.shift.lines.map { |x| x[1] }  # always nonzero
          end
          if sections.length.nonzero?
            @sections = sections
          end
        end
      end                         # don't worry, `parse_sections` is infallible.
      res
    end

    def raw_desc_lines
      if self.class.respond_to?( :desc_blocks ) and self.class.desc_blocks
        Headless::Services::Enumerator::Lines::Producer.new do |y|
          self.class.desc_blocks.each do |blk|
            instance_exec y, &blk
          end
        end
      end
    end

    parse_sections = -> do

      # `parse_sections` - the rules are simple: a line that consists of one
      # or more non-colons, and then terminated by a colon, that is a section
      # header. That may be followed by an item line which is a line that:
      # starts with one or more spaces, then any nonzero-length string
      # without two contiguous spaces in it, then two or more spaces, then the
      # first non-space and whatever comes after it. These two content-y parts
      # that were matched make up the item-line's header and body.
      # (Provisions may be made for an item-line either without a header or
      # without body). An item-line may be followed by an item sub-line, which
      # is any line immediately following an item-line or other sub-line that
      # has more indent than that last item-line. This pattern is not recursive
      # (there are no more levels of depth), and none of these need have
      # consistent indentation; it is only that the sub-lines have more
      # indentation than their host item line. Here is an e.g of the 4 kinds:
      #
      #    bleep bloop              # 1) normal line (pretend it has no indent)
      #    ferpy derpy:             # 2) this is a section hdr b/c of the ':'
      #      nerpulous  ferpulous   # 3) item line b.c space: nonzero, then >=2x
      #      bleep blop  blaugh     # 3) "bleep blop" is header, rest is body
      #        shim sham flam       # 4) item sub-line b.c more indent than 3
      #      [<path> [..]]  bazzle  # 3) something like this was the insp.
      #
      # Tabs would be trivial to add support for but they make the regexen
      # look really ugly so just don't use them. You just can't have them.
      #
      # This algorithm is infallbile and it cannot fail.


      state_h = { }  # das state machine

      state = ::Struct.new :rx, :to

      #         name               regex         which can be followed by..

      state_h[ :initial ] = state[ nil,          [ :section, :desc ] ]
      state_h[ :desc    ] = state[ //,           [ :section, :normal ] ]
      state_h[ :normal  ] = state[ //,           [ :section, :normal ] ]
      state_h[ :section ] = state[ /\A[^:]+:\z/, [ :item, :normal ] ]
      state_h[ :item    ] = state[
                         /\A(?<ind> +)(?<hdr>((?!  ).)+)(?: {2,}(?<bdy>.+))?\z/,
                                        [ :subitem, :item, :section, :normal ] ]
      state_h[ :subitem ] = state[ nil, # (<- guess what will happen here)
                                        [ :subitem, :item, :section, :normal ] ]

      module CLI::Action::Desc
        Section = ::Struct.new :header, :lines
      end

      item_rx_h = ::Hash.new { |h, k| h[k] = /\A {#{ k },}(.+)\z/ }  # cache rx

      -> lines, sections do
        stat = state_h[ :initial ]  # (var meaning change!!)
        section = line = nil
        push = -> { sections << ( section = CLI::Action::Desc::Section.new nil, [] )  }
        trigger_h = {
          desc:    -> { push[] ; section.lines << [ :line, line ] },
          section: -> { push[] ; section.header = line },
          normal:  -> {          section.lines << [ :line, line ] },
          item:    -> {          section.lines << [ :item, * $~.captures[1..-1]]
                                 state_h[:subitem].rx =  # *NOTE* not reentrant
                                   item_rx_h[ $~[:ind].length + 1 ] },
          subitem: -> {          section.lines << [ :item, nil, $~[1] ] }
        }
        while line = lines.gets
          name = stat.to.detect{ |sym| state_h[ sym ].rx =~ line }
          trigger_h.fetch( name ).call
          stat = state_h.fetch name
        end
        nil
      end
    end.call

    define_singleton_method :parse_sections do parse_sections end  # testing.

    define_method :parse_sections do |lines|
      sections = [ ]
      parse_sections[ lines, sections ]
      sections
    end

    private_attr_reader :sections  # look:

    alias_method :sections_ivar, :sections

    def sections
      if sections_ivar.nil?       # important - `build_desc_lines` is it
        desc_lines
      end
      @sections
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
    #   + your o.p must have a `visit` that works like stdlib o.p
    #   + each switch must have a `long`, `short` and `arg` that look like o.p

    private_attr_reader :option_parser  # look:

    alias_method :option_parser_ivar, :option_parser

    def option_parser
      if option_parser_ivar.nil?  # (mutex-out subsequent calls to b.o.p
        @option_parser = build_option_parser || false  # unless user nillifies)
      end
      @option_parser
    end
    protected :option_parser      # #protected-not-private
                                  # mutate `argv` (which is probably also @argv)
    def parse_opts argv           # what you do with the data is your business.
      res = true                  # result in true on success, other on failure
      begin
        break if argv.length.zero? # don't even build option parser.
        break if is_branch && Headless::CLI::Option::Constants::
          OPT_RX !~ argv.first # ambig. grammars [#024]
        break if ! option_parser  # leave brittany alone, downstream gets argv
        # `option_parser` can be some fancy arbitrary thing, but it needs to
        # conform to at least these two parts of stdlib ::O_P..
        begin
          option_parser.parse!( argv ) { |b| instance_exec(& b ) } # hack
        rescue Headless::Services::OptionParser::ParseError => e
          usage_and_invite e.message
          res = exit_status_for :parse_opts_failed
        end
      end while nil
      if true == res && param_queue_ivar
        res = absorb_param_queue  # (here. see `param_queue`)
      end
      res
    end

    def rndr_switch sw            # (hook for shenanigans)
      if sw.short || sw.long      # nerculouses composed of just a rx, for e.g
        "[#{ (sw.short && sw.short.first) or (sw.long && sw.long.first) }#{
          }#{ sw.arg }]"
      end
    end
                                  # nil when no o.p, nil when no visible opts
                                  # there is currently no unstyled form but..
    def render_option_syntax      # ..one could be made. also this does not
      if option_documenter        # currently style but one could be made.
        a = visible_options.reduce [] do |m, sw|
          s = rndr_switch sw
          m << s if s
          m
        end
        a.join ' ' if a.length.nonzero?
      end
    end
                                  # assume o.p complete, use hack, o.p compat
    def visible_options           # maybe zero length, kept flat & functiony
      ::Enumerator.new do |y|
        option_is_visible_in_syntax_string || nil # kick, ick
        CLI::Option::Enumerator.new( option_documenter ).each do |sw|
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

    def argument_syntax_for_method meth_x
      meth_i = meth_x.intern
      argument_syntax_cache.fetch meth_i do
        @argument_syntax_cache_h[ meth_i ] = build_arg_stx meth_i
      end
    end

    def build_arg_stx meth_i
      Headless::CLI::Argument::Syntax::Inferred.
        new method( meth_i ).parameters, formal_parameters  # f.p nil ok
    end

    # a #view-template-ish for rendering a particular argument syntax object
    # into a styled string. result is nil if the syntax has no elements,
    # otherwise a non-zero length, possibly styled string. With `em_range`
    # you can emphasize a contiguous subset of the elements. (there is
    # significance that this happens here and not in an auxiliary object)

    def render_argument_syntax stx, em_range=nil  # of the elements.
      y = []
      render_base_arg_syntax_parts y, stx, em_range
      append_syntax y
      y * ' ' if y.length.nonzero?
    end

    def render_base_arg_syntax_parts y, stx, em_range=nil
      stx.each.with_index do |arg, d|
        s = render_argument_text arg
        if em_range and em_range.include? d
          s = em s
        end
        y << s
      end ; nil
    end

    def append_syntax y  # for custom hacky syntaxes
      if self.class.respond_to? :append_syntax_a
        a = self.class.append_syntax_a
      end
      a and y.concat a ; nil
    end

  public
    def render_argument_text arg       # (no styling just text)
      a, b = reqity_brackets arg.reqity
      if arg.is_atomic_variable
        "#{ a }<#{ arg.as_slug }>#{ b }"
      elsif arg.is_collection
        "#{ a }#{ arg.render_under self }#{ b }"
      else
        "#{ a }#{ arg.as_moniker }#{ b }"
      end
    end
    #
    def render_group_with_i_and_a i, a
      sep = CLI::Action::SEPARATOR_GLYPH_H__.fetch( i )
      a * sep
    end
    #
    CLI::Action::SEPARATOR_GLYPH_H__ = { series: ' ', alternation: '|' }.freeze
  private

    -> do
      reqity_brackets = nil  # load it wherever it is only when you need it
      define_method :reqity_brackets do |reqity|
        ( reqity_brackets ||= CLI::Argument::FUN::Reqity_brackets )[ reqity ]
      end
    end.call

    def validate_arity_for meth_i, args
      r = argument_syntax_for_method meth_i
      r &&= with_argument_syntax_process_args( r, args )
      r
    end

    def with_argument_syntax_process_args syn, args
      syn.process_args args do |o|
        o.on_missing method :handle_missing_args
        o.on_result_struct method :handle_args_result_struct
        o.on_unexpected method :handle_unexpected_args
      end
    end

    def handle_missing_args e
      send handle_missing_args_op_h.fetch( e.orientation ), e
    end
    #
    def handle_missing_args_op_h
      CLI::Action::HMA_OP_H__
    end
    #
    CLI::Action::HMA_OP_H__ = { vertical: :handle_missing_args_vertical,
      horizontal: :handle_missing_args_horizontal }.freeze

    def handle_missing_args_vertical e
      usage_and_invite "expecting: #{ render_expecting_term e }"
      exit_status_for :argv_parse_failure_missing_required_arguments
    end

    def render_expecting_term e
      fragment = e.argument_a
      _a = fragment[ 0 .. fragment.index { |x| :req == x.reqity } ]
      render_argument_syntax _a, 0..0
    end

    def handle_missing_args_horizontal e
      y = [ ]
      e.argument_a.each do |arg|
        x = if arg.is_literal then  "`#{ arg.as_moniker }`"
        else render_argument_text arg end
        x and y << x
      end
      _s = render_group_with_i_and_a :alternation, y
      if (( token_set = e.any_at_token_set ))
        1 == token_set.length or fail 'test me'
        _near_s = " at #{ ick token_set.to_a.first }"
      end
      usage_and_invite "expecting { #{ _s } }#{ _near_s }"
      exit_status_for :argv_parse_failure_missing_required_arguments
    end

    def handle_args_result_struct st
      absorb_result_struct_into_param_h st
    end

    def absorb_result_struct_into_param_h st
      st.members.each { |i| @param_h[ i ] = st[ i ] }
      nil
    end

    def handle_unexpected_args e
      a = e.s_a
      usage_and_invite "unexpected argument#{ s a }: #{ ick a[0] }#{
        }#{" [..]" if a.length > 1 }"
      exit_status_for :argv_parse_failure_unexpected_arguments
    end

    #         ~ `parameters` - abstract reflection and rendering ~

    def param norm_name
      parm = fetch_parameter norm_name
      if parm.is_option
        parm.as_parameter_signifier
      elsif parm.is_argument
        render_argument_text parm
      end
    end

    def fetch_parameter norm_name, &otr
      as = argument_syntax
      if as
        rs = as.fetch_parameter norm_name do end
      end
      if ! rs and option_parser and @option_parser.respond_to? :fetch_parameter
        rs = @option_parser.fetch_parameter norm_name do end
      end
      if rs then rs else
        ( otr || -> { raise ::KeyError,
                      "parameter not found: #{ norm_name.inspect }" } ).call
      end
    end
  end
end
