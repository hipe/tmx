module Skylab::Face

  # `Face`
  #   + wraps around ::OptionParser by default
  #   + renders styled help screens and the usual help UI
  #   + arbitrarily deeply nested sub-commands (namespaces)
  #   + nodes (commands and namespaces) can have aliases
  #   + fuzzy matching
  #   + command argument syntax inferred by default from method signature
  #   + some built in 'officious' (allà stdlib o.p) like -v, -h

  # (historical note - this one came before headless, before porcelain
  # (both `bleeding` and `legacy` i think, indeed it was the first client
  # library for `tmx` itself) and it did not age well, but then saw a
  # ground-up test-driven rewrite after all of those. it will hopefully
  # be merged into headless one day because now it is close to perfect.)

  # We try to follow "narrative pre-order" ([#hl-058]) below. The uptake is
  # classes and modules are re-opened as necessary so as to fit method
  # definitions within the appropriate section, to make a rousing narrative,
  # and to make it semantically modular, if we ever need to break it up.

  class Command  # (fwd declare)
  end

  module TreeDefiner  # (fwd delcare)
  end

  class Namespace < Command  # (fwd declare)
    extend TreeDefiner
  end

  class CLI < Namespace

    def self.inherited cls
      super  # kray
      cls.init_namespace NS_Sheet.new( cls )  # Namespace classes

        # - like many other entities here - internally store their business
        # data in a "character-sheet"-ish object (called a "story" when
        # it is in regards to a namespace). A namespace's story consists of
        # (among other things) one sheet for each of its child nodes.
        # (deeply nested namespaces are then stories inside stories yay.)

      cls.story.add_option BRANCH_HELP  # (if you want to change (e.g remove)
        # this default branch-help behavior in your clients you have several
        # options, including hacking the `story.options` ary in your class
        # (e.g use `reject` or `pop`))
    end

    #       ~ the existential public workhorse method `run` & support ~

    def run argv    # public form that is defined here in superclass,
      invoked argv  # protected form that child class may override without
    end             # unintentionally creating an action via a public method :/

  protected  # `run` support (pre-order)

    def invoked argv  # funny n-ame to distinguish it from `invoke` is important!
      if argv.length.zero?
        _, res = empty_argv
        res
      else
        branch = self ; stay = true
        begin
          if '-' == argv[0][0]
            stay, res = branch.process_options argv
            stay or break
          end
          stay, res = branch.find_command argv
          stay or break
          cmd = res
          if cmd.respond_to? :invokee
            stay = false
            break( res = cmd.invokee.invoke argv )
          end
          cmd.respond_to? :find_command or break
          branch = cmd  # tail-call like
        end while argv.length.nonzero?

        if ! stay then res else
          stay, res = cmd.parse argv
          if ! stay then res else
            begin
              branch.send cmd.method_name, * argv
            rescue ::ArgumentError => ex  # ick this ain't right
              argument_error ex, cmd  # this position is locked in the stack!
            end
          end
        end
      end
    end

    # ick this is legacy and slated for removal # #todo. back then it seemed
    # easier (and indeed had more noveltly) to let this isomorphicism extend
    # all the way up to this level but nowadays it looks more ugly than elegant
    # but who knows it is in the spirit of this whole thing .. [#004]

    def argument_error ex, cmd  # result will be final result
      one = ex.backtrace[ 1 ]
      md = Services::Headless::FUN.call_frame_rx.match one
      if ! ( __FILE__ == md[:path] && 'invoked' == md[:meth] )
        raise ex  # then it didn't originate from the above spot .. ICK
      else
        @y << ex.message
        cmd.usage @y
        cmd.invite @y
        nil  # final-result
      end
    end

    #            ~ terminal versions of up-delegator methods ~
    #               ( public for children, as in parent )

  public
    def invocation_string
      @program_name || ::File.basename( $PROGRAM_NAME )
    end

    attr_reader :margin, :in, :out, :err

  protected

    -> do  # `initialize`

      margin, out, err = '  '.freeze, $stdout, $stderr

      opt_h_h = {
        in:  -> v { @in  = v },
        out: -> v { @out = v },
        err: -> v { @err = v },
        program_name: -> v { @program_name = v },
        sheet: -> v do # NOTE EXPERT MODE this shit kray
          @sheet = v   # passing an arbitrary sheet in can have arbitray results
        end            # note this call happens right after parent sets sheet
      }
      define_method :initialize do |opt_h=nil|
        if block_given?
          raise ::ArgumentError.new "this crap comes back after #100"
        end
        super nil, nil  # request client, slug_fragment
        if opt_h
          opt_h.each { |k, v| instance_exec v, & opt_h_h.fetch( k ) }
        end
        @program_name ||= nil
        @margin ||= margin
        # (we let @in remain unset, it does not get defaulted. it is special)
        @out ||= out
        @err ||= err
        @y = ::Enumerator::Yielder.new(& @err.method( :puts ) )  # `help_yielder`
      end
    end.call

    module Adapter
      extend MAARS
    end
  end

  class Option_Sheet

    # the abstract representation of an option, so you can store the
    # arguments passed to `on` before you build the o.p

    attr_reader :args, :block, :is_fully_visible

    def is_single_option
      true
    end

    def initialize args, blk, is_fully_visible=true
      @args, @block, @is_fully_visible = args, blk, is_fully_visible
    end
  end

  BRANCH_HELP = Option_Sheet.new(
    [ '-h', '--help [cmd]', 'this screen [or sub-command help]' ].freeze,
    -> x do
      @queue_a ||= [ ]
      if ! x then @queue_a << :help else
        args = [ x ]  # cutely scoop any subsequent args off argv.
        while @argv.length.nonzero? and '-' != @argv[0][0]
          args << @argv.shift
        end
        @queue_a << [ :subcommand_help, * args ]
      end
    end,
    false ).freeze

  VERSION = Option_Sheet.new(  # implemented by `CLI`
    [ '--version', 'show version' ].freeze,
    -> { ( @queue_a ||= [ ] ) << :show_version }
  ).freeze

  FN = MetaHell::Formal::Box::Open.new  # get ready

  class Node_Sheet

    def is_leaf
      ! is_branch
    end

    def slug
      @name_function.as_slug if name_function
    end

    def normalized_local_command_name
      @name_function.normalized_local_name if name_function
    end

    def name_function= x
      @aliases_are_puffed = nil
      @name_function = x
    end

    def add_aliases arr
      @aliases_are_puffed = nil
      ( @alias_a ||= [ ] ).concat arr
      nil
    end

    def all_aliases
      if ! name_function then FUN.empty_a else  # otherwise too annoying
        if ! @aliases_are_puffed
          @all_alias_a ||= [ @name_function.as_slug ]  # NOTE strings important
          if @alias_a
            w = ( @alias_a.length - @all_alias_a.length + 1 )
            if w.nonzero?
              @all_alias_a.concat(
                @alias_a[ @all_alias_a.length - 1 .. -1 ].map(& :to_s ) )
            end
          end
          @aliases_are_puffed = true
        end
        @all_alias_a
      end
    end

    def initialize
      @name_function = @alias_a = @all_alias_a = @aliases_are_puffed = nil
    end
  end

  class NS_Sheet < Node_Sheet

    # the abstract represntation of a namespace. before you build any
    # actual things, you can aggreate the data around it progressively.


    #   ~ terminal (monadic) constituent nodes, writers & readers ~

    def is_branch
      true
    end

    attr_reader :host_module

    def name_function
      if @name_function.nil?
        @name_function = if ! @norm then false else
          Services::Headless::Name::Function.new @norm
        end
      end
      @name_function
    end

    alias_method :name, :name_function  # (please don't use this bare)

    # `method_name` ( namespace edition ) - only when argv terminates on
    # a branch.

    def method_name
      @empty_argv_method_name
    end

    def mod_ref= mod_ref
      if @mod_ref
        raise ::ArgumentError, "won't clobber existing mod ref"
      else
        @mod_ref = mod_ref
      end
    end

    #   ~ non-terminal (list-like) constituent nodes, writers & readers ~

    def add_block block
      if @mod_ref
        raise ::ArgumentError, "cant't add block to #{ @mod_ref }"
      else
        @mod_blocks << block
      end
      nil
    end

    def on first, *rest, &blk
      add_option Option_Sheet.new( rest.unshift( first ), blk )
    end

    def add_option option_sheet
      ( @options ||= [ ] ) << option_sheet
      nil
    end

    attr_reader :options

    def option_parser &blk  # NOTE own option parser. so named for consistency
      add_option Option_Block.new( blk )
    end

    def child_option_parser &blk
      current_leaf!.add_option_parser_block blk
    end

    def current_leaf!
      if ! @current_leaf
        @current_leaf = Leaf_Sheet.new nil  # no method name yet.
      end
      @current_leaf
    end
    protected :current_leaf!

    def add_child_aliases arr
      current_leaf!.add_aliases arr
    end

    def the_method_was_added meth
      @current_leaf.method_name = meth
      cl = @current_leaf ; @current_leaf = nil
      @box.add cl.normalized_local_command_name, cl
      nil
    end

    def namespace norm, *ref_xtra_h, &block
      write_ns norm, -> ns do
        ns.absorb( *ref_xtra_h, &block )
        nil
      end, -> do
        NS_Sheet.new nil, norm, *ref_xtra_h, &block  # important response
      end
      nil  # our internal struct is internal
    end

    def write_ns norm, yes, no  # internally used to create or update n.s
      if @current_leaf
        raise "can't add namespace when command is still open - #{ norm }"
      else
        @box.if? norm, -> ns do
          if ns.is_leaf
            raise "attempt to reopen a command as a namespace - #{ norm }"
          else
            yes[ ns ]
          end
          nil
        end, -> do
          ns = no[] or raise "expecting `no` block to produce namespace"
          @host_module.order_a << norm
          @box.add norm, ns
          nil
        end
      end
      nil  # our internal struct is internal
    end
    protected :write_ns

    def add_namespace ns_sheet  # for hacks
      write_ns ns_sheet.normalized_local_command_name, -> ns do
        fail 'implement me - merge sheets'
      end, -> do
        ns_sheet
      end
    end

    def if_element norm, yes, no
      @box.if? norm, yes, no
    end

    def fetch_element norm, &no
      @box.fetch norm, &no
    end

    def command_tree
      if ! @is_reified
        @is_reified = true  # future-proof the avoiding of re-entrancy
        addme = @host_module.public_instance_methods( false ) - @box._order
        addme.each do |norm|
          @box.add norm, Leaf_Sheet.new( norm )
        end
        order_h = ::Hash[ @host_module.order_a.each_with_index.to_a ]
        @box.sort_names_by! do |nam|
          order_h.fetch nam do
            raise ::KeyError, "element (namespace?) name not found in order #{
              }list (#{ nam.inspect } in #{ @host_module.order_a.inspect })"
          end
        end
      end
      @box.length.zero? ? false : @box
    end

    attr_writer :hot  # write the hot function yourself

    -> do

      mod_blocks = nil

      define_method :hot do |rc, rc_sheet, slug_fragment|
        if ! @hot
          if ! @host_module
            if @mod_blocks
              instance_exec rc_sheet, & mod_blocks
            else
              strange_mod = @mod_ref.call
              @mod_ref = nil
              @hot = strange_mod::Adapter::For::Face::Of::Hot[ strange_mod ]
            end
          end
          if @host_module && ! @hot
            @hot = -> sht, req_client, rc_sht, slug_frag do
              @host_module.new req_client, slug_frag
            end
          end
        end
        @hot.call self, rc, rc_sheet, slug_fragment
      end

      box_mod = nil

      mod_blocks = -> rc_sheet do
        box = box_mod[ rc_sheet ]
        kls = box.const_set self.name.as_const, ::Class.new( Namespace )
        kls.init_namespace self
        kls.story.add_option BRANCH_HELP
        @host_module = kls  # important! before below.
        @mod_blocks.each do |blk|
          kls.class_exec(& blk )     # MONEY MONEY MONEY MONEY MONEY MONEY MONEY
        end
        @mod_blocks = nil
        nil
      end

      box_mod = -> rc_sheet do
        hm = rc_sheet.host_module
        if hm.const_defined? :Commands, false
          hm.const_get :Commands, false
        else
          hm.const_set :Commands, ::Module.new
        end
      end
    end.call

    # `initialize` - it became unholy because we had to underload the signature
    # while trying to reign-in 30 different subproducts and libraries

    -> do  # `initialize`, `absorb`
      norm_h = {
        0 => -> block do
          # block or raise ::ArgumentError, "block or module ref expected."
          [ nil, nil, block ]
        end,
        1 => -> mod_ref, block do
          block and raise ::ArgumentError, "can't have block & mod ref"
          [ mod_ref, nil, nil ]
        end,
        2 => -> mod_ref, xtra_h, block do
          block and raise ::ArgumentError, "can't have block & mod ref"
          [ mod_ref, xtra_h, nil ]
        end
      }

      define_method :initialize do |host_module, norm=nil, *ref_xtra_h, &block|
        super( )
        @empty_argv_method_name = :empty_argv
        @host_module = host_module
        @current_leaf = @is_reified = @hot = @hot_class = @options = nil
        @box = MetaHell::Formal::Box::Open.new
        @norm = norm if norm  # else trigger warnings when accessing the ivar
        @mod_ref, xtra_h, mod_block =  # mutex on @mod_ref vs @mod_block !
          norm_h.fetch( ref_xtra_h.length )[ *ref_xtra_h, block ]
        absorb_xtra_h xtra_h if xtra_h
        @mod_blocks = ( [ mod_block ] if mod_block )
        self
      end
      protected :initialize

      xtra_h_h = {
        aliases: -> v { add_aliases v }
      }

      define_method :absorb_xtra_h do |xtra_h|
        xtra_h.each do |k, v|
          instance_exec v, & xtra_h_h.fetch( k )
        end
        nil
      end

      define_method :absorb do |*ref_xtra_h, &block|
        mod_ref, xtra_h, mod_block =
          norm_h.fetch( ref_xtra_h.length )[ *ref_xtra_h, block ]
        if mod_ref
          self.mod_ref = mod_ref
        elsif mod_block
          add_block mod_block
        end
        absorb_xtra_h xtra_h if xtra_h
        nil
      end
    end.call
  end

  class Leaf_Sheet < Node_Sheet # created by N-S_Sheet. probably a command.

    def is_branch
      false
    end

    def add_option_parser_block blk
      ( @option_parser_blocks ||= [ ] ) << blk
    end

    def name_function
      if @name_function.nil?
        @name_function = if ! @method_name then false else
          Services::Headless::Name::Function.new @method_name
        end
      end
      @name_function
    end

     # `hot` - a hot, live action (er, command) is requested
    def hot rc, rc_sheet, alias_used
      Command.new rc, self, alias_used
    end

    attr_reader :block, :method_name  # Command wants to see you in his office

    def method_name= x
      if @method_name
        raise "won't clobber method name"
      else
        @method_name = x
      end
    end

    def options
      if @option_parser_blocks && @option_parser_blocks.length.nonzero?
        @option_parser_blocks.map! { |b| Option_Block.new b }
        ( @options ||= [ ] ).concat @option_parser_blocks
        @option_parser_blocks = nil
      end

      @options
    end

  protected

    def initialize method_name=nil
      super( )
      @options = @option_parser_blocks = nil
      @method_name = method_name  # nil ok
    end
  end

  class Option_Block < ::Struct.new :block

    # the abstract representation of an option block, lets it get processed
    # harmoniously inline with `Option_Sheet`

    def is_single_option
      false
    end

    def is_fully_visible
      true
    end
  end

  class Command

    # @todo:#100.100.400 rename to 'Action'  (maybe..)

    # (note the pattern that emerges in the order)

  protected  # something strange is going on..

    # existential workhorse `process_options` - called from main loop

    def process_options argv, do_permute=false
      @argv = argv  # monadic. experimental. some switches do custom hacks
                                               # assume '-' == argv[0][0]
                                               # if no o.p, yet there is '-',
      if ! option_parser then true else        # this will probably soft bork
        begin                                  # parse destructively, in order
          if do_permute                        # (permute is typically used
            @op.permute! argv                  # for terminal nodes ("commands")
          else                                 # as op. to namespaces.)
            @op.order! argv                    # NOTE stop at 1st non-{arg|opt}!
          end
        rescue ::OptionParser::ParseError => e
          parse_error = true                   # don't linger in this frame
        end
        if parse_error
          reason highlight_header( e.message ) # then don't stay. short-
          [ false, nil ]                       # circuit. early completion.
        else
          option_parser_host.process_queue
        end
      end
    end

    # `process_options` support

    def option_parser  # (this is not the `documenter`)
      @op.nil? and init_op
      @op
    end

    attr_reader :op
    protected :op  # experts only

    def init_op
      if true
        @op = op = build_empty_option_parser # set it now, blocks use it
        @ugly_str, @ugly_id = op.banner.dup, op.banner.object_id
          # the above is for a documenting hack. make a note of these 2 things.
        cmd = self
        use_options = @sheet.options || FUN.empty_a
        option_parser_host.instance_exec do
          op.base.long['help'] = op.class::Switch::NoArgument.new do
            ( @queue_a ||= [ ] ) << [ :show_help, cmd ]
          end  # life is easier. invisible option overrides stdlib, which exits
          use_options.each do |sheet|
            if sheet.is_single_option  # (`on`)
              if sheet.block.arity.zero?
                op.define(* sheet.args ) do
                  instance_exec( & sheet.block )
                end
              else
                op.define(* sheet.args ) do |v|
                  instance_exec v, & sheet.block
                end
              end
            else
              @command = cmd  # some o.p blocks want it both ways
              instance_exec op, & sheet.block  # (`option_parser`)
              @command = nil
            end
          end
        end
      end
      nil
    end

    def build_empty_option_parser
      op = Face::Services::OptionParser.new
      op.base.long.clear  # no builtin -h or -v
      op
    end

    def option_parser_host  # a command is not the context for its blocks
      @parent
    end

    -> do  # `highlight_header` (first seen in `process_options`)

      header_rx = /\A([^:]+:)/

      define_method :highlight_header do |str|
        str.sub header_rx do
          "#{ hi $1 }"
        end
      end
      protected :highlight_header
    end.call

    #     ~ ( formerly 'Colors` (still '`process_options` support'!) ) ~
    def hi str  # WAS: ohno=red; yelo=yellow, bold=(bright,green);
      style str, :green
    end

    -> do  # `style`

      h = { bright: 1, red: 31, green: 32, yellow: 33, cyan: 36, white: 37 }

      esc = "\e"  # "\u001b" ok in 1.9.2

      define_method :style do |str, *styles|
        codes = styles.reduce [] do |m, x|
          if ::Integer === x then m << x else
            xx = h[ x ] and m << xx
          end
          m
        end
        "#{ esc }[#{ codes * ';' }m#{ str }#{ esc }[0m"
      end
      protected :style
    end.call

    def reason txt  # atypical early exit with reason, first in `proces_opts`
      @y << txt
      invite @y
      nil
    end

    def invite y
      y << "Try #{ hi "#{ @parent.invocation_string } -h #{ slug }" } #{
        }for help."
      nil
    end

    def slug
      @sheet.slug
    end

    def process_queue                          # from `process_options`
      if ! @queue_a || @queue_a.length.zero?   # then stay. any opts parsed
        true                                   # added nothing to queue.
      else                                     # then activity happened, our
        stay = true
        begin
          meth, *args = @queue_a.shift
          sty, res = send meth, *args          # every element is always run
          ( stay &&= sty ) or break            # (unless..)
        end while @queue_a.length.nonzero?     # stay = sty && sty && sty
        [ stay, res ]                          # res is last res
      end
    end

    # existential workhorse `parse` - requested from main loop

    # like `process_options` but for a terminal node ("command")
    def parse argv
      if option_parser
        process_options argv, true  # very likely [ nil, nil ]
      else
        # #todo
        fail 'test me - you have to try hard not to have an o.p'
        true
      end
      # only because of [#004] we don't do what is right (for now)
    end

    FN[:empty_a] = [ ].freeze  # `empty_a` - detect shenanigans, have ocd

    # existential workhorse `help` (request may come in from parent -h)

    def show_help cmd
      stay, res = cmd.help
      if stay then [ stay, res ] else
        [ @queue_a.length.nonzero?, res ]
      end
    end

    # `help` - result is a response pair when argv is present.

    def help
      @is_puffed or puff
      y = @y
      if documenter
        y << @op.banner  # (cognizant of hack)
        @op.summarize y
      else
        y << usage_line
      end
      additional_help y
      # rather than ignoring args that came after us, we will let the main
      # loop decide what to do with them. stay if any args left.
      [ @argv && @argv.length.nonzero?, nil ]
    end

  protected  # `help` support

    # maybe hackishly, maybe not, but our `documenter` is our option parser
    # (the same instance) but with the banner maybe set to an enhanced string.

    def documenter
      if has_partially_visible_op
        @op.nil? and init_op
        @did_prerender_help ||= prerender_help
        @op
      end
    end

    def has_fully_visible_op
      @sheet.options && @sheet.options.detect(& :is_fully_visible )
    end

    def has_partially_visible_op
      @sheet.options && @sheet.options.length.nonzero?
    end

    def prerender_help
      # we only "enchance" the main o.p if you didn't write or modify your
      # own banner (very ICK but also kind of MEH)
      if @ugly_str == @op.banner && @ugly_id == @op.banner.object_id
        y = [ ]
        usage y
        sum = @op.base.list.length + @op.top.list.length
        if sum.nonzero?
          y << "#{ hi "option#{ 's' if 1 != sum }:" }" # `options:` (#2 of 2)
        end
        @op.banner = y * "\n"
      end
      true  # important!
    end

    def usage y
      y << usage_line
      x = additional_usage_lines and y.concat x
      nil
    end

    def usage_line
      "#{ hi usage_header_text } #{ syntax }"
    end

    -> do  # `usage_header_text`
      txt = 'usage:'.freeze
      define_method :usage_header_text do txt end
      protected :usage_header_text
    end.call

    def additional_usage_lines
    end  # for now this only happens at branch nodes.

    def syntax
      x = nil
      a = [ invocation_string ]
      a << x if ( x = option_syntax )
      a << x if ( x = argument_syntax )
      a * ' '
    end

    def invocation_string
      "#{ @parent.invocation_string } #{ @sheet.slug }"
    end  ; public :invocation_string  # up-delegator

    def option_syntax
      if option_parser && has_partially_visible_op
        a = each_option.reduce [] do |m, opt|
          m << "[#{ opt.as_shortest_full_parameter_signifier }]"
        end
        a * ' ' if a.length.nonzero?
      end
    end

    def each_option  # assumes that @op (when constructed) will be an o.p
      @op_enum ||= begin
        @op.nil? and init_op
        opt = Services::Headless::CLI::Option.new_flyweight
        ea = Services::Headless::CLI::Option::Enumerator.new @op
        ea.filter = -> sw do
          opt.replace_with_switch sw
          opt
        end
        ea
      end
    end

    -> do  # `argument_syntax`
      reqity_brackets = nil

      define_method :argument_syntax do
        method = @parent.method @sheet.method_name
        parts = method.parameters.reduce [] do |m, x|
          a, z = ( reqity_brackets ||=  # narrow the focus of the dep for now
            Services::Headless::CLI::Argument::FUN.reqity_brackets )[ x[0] ]
          m << "#{ a }<#{ FUN.slugulate[ x[1] ] }>#{ z }"
        end
        parts * ' ' if parts.length.nonzero?
      end
    end.call

    FN[:slugulate] = -> x do
      Services::Headless::Name::FUN.slugulate[ x ]
    end  # (narrow focus of the dependency for now, despite triviality of impl.)

    def additional_help y  # (hook for child classes to exploit handily)
    end

    # existential workhorses: `method_name`, `summary`

    def method_name  # called when the `parse` was successful - remember
      @sheet.method_name  # it is not we who actually execute the implementation
    end

    -> do  # `summary` idem. # NOTE **lots** of goofing around here # #todo

      hack_excerpt_from_option_parser = -> do
        # this terrific hack tries to distill a summary out of the first one
        # or two lines of the option parser -- it strips out all styling from
        # them (b.c it looks wrong in summaries), and indeed strips out the
        # styled content all together unless (ICK) that header says "usage:"
        # #experimental proof-of-concept novelty hack. not actually ok.

        #                       ~ pre-order ~

        hl_is_loaded = load_hl = unstylize_sexp = parse_styles = chunker =
          a_fex_lines_rx = header_rx = excerpt_str_h = unstyle_h = nil

        first_lines = nil
        hack_exp_fr_op = -> op, usage_header_txt do
          hl_is_loaded || load_hl[]
          lines = first_lines[ op, 2 ]
          excerpt_str_h ||=
            {  1 => -> a { a[0] },
               2 => -> a { "#{ a[0] } [..]" } }
          exrp_s = excerpt_str_h.fetch( lines.length ).call lines
          sexp = parse_styles[ exrp_s ]
          if ! sexp then [ exrp_s ] else  # if there was no styling we are done
            enum = chunker::Enumerator.new sexp
            unstyle_h ||= {
              string: -> m, x do
                m << unstylize_sexp[ x ]
                nil
              end,
              style: -> m, x do
                s = unstylize_sexp[ x ]
                # ICK only let a header through if it says "usage:" ICK
                m << s if usage_header_txt == s || header_rx !~ s
                nil
              end
            }
            pts = enum.reduce [] do |m, x|
              unstyle_h.fetch( x[0][0] )[ m, x ]
              m
            end
            [ pts.join( '' ).strip ]
          end
        end

        # because we just can't bare the thought of rendering the whole o.p..
        first_lines = -> op, num do
          lines = op.banner.split( "\n" )[ 0, num ]
          if lines.length < num
            catch :face_hack do
              op.summarize do |s|
                lines << s
                throw :face_hack if num <= lines.length
              end
            end
          end
          lines
        end

        load_hl = -> do
          # lazy load these, might be a beast, and the dependency is awkward
          chunker = Services::Headless::CLI::Stylize::Chunker
          parse_styles, unstylize_sexp =
            Services::Headless::CLI::FUN.at :parse_styles, :unstylize_sexp
          hl_is_loaded = true
        end

        # a_few_lines_rx = /\A[\n]*([^\n]*)(\n+[^\n])?/
        # (in case we ever go back to op.to_s, this is what we used #todo)

        header_rx = /\A[^ ]+:[ ]?\z/  # no tabs [#hl-055]

        hack_exp_fr_op
      end.call

      define_method :summary do
        if documenter
          exrp_a = hack_excerpt_from_option_parser[ @op, usage_header_text ]
        end
        if exrp_a then exrp_a else
          [ "usage: #{ syntax }" ]  # like `usage_line` but unstylized
        end
      end
    end.call

    def out  # here for proximity to `include` b.c it feels right
      @parent.out
    end

  protected

    def initialize request_client, sheet, slug_fragment
      @argv = nil  # only set in one place. usually for command-like options.
      @did_prerender_help = @op = nil
      @is_puffed = true  # nerks that want to do some loading can set to false
      @queue_a = nil  # allows transactional o.p, command-like options.
      if request_client
        @parent = request_client
        @y = @parent.error_stream_yielder
      end
      @sheet = sheet if sheet
      # `slug_fragment` not currently stored. what the user typed is unimportant
    end
  end

  class Namespace

    Adapter = CLI::Adapter  # this puts the constant in the scope of n.s subclss

    #                 ~ parts of our DSL and cetera ~

    class << self  # for now but we might etc..

      def inherited cls
        cls.class_exec do
          @do_grab_next_method = nil
          @order_a = [ ]
        end
      end

      def init_namespace sheet
        @story = sheet
      end

      def story
        @story  # trigger warnings
      end

      def order_a
        @order_a  # triggers warnings
      end

    protected

      def on first, *rest, &b
        @story.on first, *rest, &b
      end

      def option_parser &blk
        @do_grab_next_method = true  # clobbering existing true is fine.
        @story.child_option_parser( &blk )
        nil
      end

      def aliases *aliases
        @story.add_child_aliases aliases
      end

      def namespace norm, *ref_xtra_h, &block
        if ! @story.host_module
          fail 'where'
        end
        @story.namespace norm, *ref_xtra_h, &block
      end
    end

  protected  # (shadow `process_options` support)

    def option_parser_host
      self  # differnt from command, whose host is parent; when we build
    end  # an o.p it is because we ourselves are making one for ourself.

    def invite y
      y << "Try #{ hi("#{ invocation_string } -h [sub-cmd]")} for help."
      nil
    end

    # existential workhorse `find_command` - called from main loop

    # `find_command` - remove at most 1 element off the head of `argv`.
    # result in approriate response pair - if command can be resolved,
    # a *hot* subcommand is the payload element of the pair.

    def find_command argv  # workhorse - result in hot subcommand
      if argv.length.zero? then empty_argv else
        given = argv.first
        rx = /\A#{ ::Regexp.escape given }/
        @is_puffed or puff
        found_a = catch :break_two do
          if ! @sheet.command_tree then [] else
            @sheet.command_tree.reduce [] do |memo, (_, node)|
              num = node.all_aliases.reduce 0 do |m, nm|
                if given == nm
                  throw :break_two, ( memo.clear << node )
                end
                rx =~ nm ? ( m + 1 ) : m  # keep looking, maybe exact match
              end
              memo << node if num.nonzero?
              memo
            end
          end
        end
        case found_a.length
        when 0 ; unrecognized_command given
        when 1 ; [ true, ( found_a[ 0 ].hot self, @sheet, argv.shift ) ]
        else   ; ambiguous_command found_a, given
        end
      end
    end

    # `find_command` support

    def empty_argv
      # used to have `default_action` logic but that is being rebuilt
      reason "Expecting #{ expecting }."
      [ false, nil ]
    end

    def expecting  # styled
      @is_puffed or puff
      if ! @sheet.command_tree then 'nothing' else  # cute
        a = @sheet.command_tree.reduce [] do |m, (_,x)|
          m << "#{ hi x.slug }"
        end
        a * ' or '
      end
    end

    def unrecognized_command given
      reason "Unrecognized command: #{ given.inspect }. #{
        }Expecting: #{ expecting }"
      [ false, nil ]
    end

    def ambiguous_command found, given  # #todo not covered
      reason "Ambiguous command: #{ given.inspect }. #{
        }Did you mean #{ found.map{ |c| hi c.slug } * ' or ' }?"
      [ false, nil ]
    end

    # `help` support (shadowing the order of parent)

    def subcommand_help command, *rest # (as a shadow of `help`)
      argv = rest.unshift command  # (to be clear, it is a contiguous subset
                                   # of the received argv)
      branch = self
      while true  # imagine `find_command_recursive`
        stay, cmd = branch.find_command argv
        stay or break
        argv.length.zero? and break
        if ! cmd.respond_to? :find_command
          stay, res = false, nil
          @y << "Unexpected argument#{ 's' if 1 != argv.length }: #{
            }#{ argv[0].inspect }#{ ' [..]' if 1 < argv.length }"
          @y << "#{ hi usage_header_text } #{ invocation_string } #{
              parameters.fetch( :help ).as_shortest_nonfull_signifier
            } [cmd [sub-cmd [..]]]"
          invite @y
          break
        end
        branch = cmd
      end
      if ! stay then [ stay, res ] else
        subcmd_help cmd  # just a little hook
      end
    end

    -> do  # `parameters` - goofing around
      pxy = nil
      define_method :parameters do
        pxy ||= ( Face::Parameters = MetaHell::Proxy::Nice.new :fetch )
        @parameters ||= pxy.new(
          fetch: -> ref, &blk do
            stay = false
            res = options.fetch ref do stay = true end
            if stay
              res = arguments.fetch ref do stay = false end   # etc #todo
              if ! stay  # meh
                blk ||= -> _ { raise ::KeyError, "not found - #{ ref }" }
                res = blk[ ref ]
              end
            end
            res
          end
        )
      end
      protected :parameters
    end.call

    -> do  # `options` - goofing around
      pxy = nil
      define_method :options do
        pxy ||= ( Face::Options = MetaHell::Proxy::Nice.new :fetch )
        @options ||= -> do
          scn = nil
          op = option_parser ? @op : FUN.emtpy_a
          pxy.new(
            fetch: -> ref, &blk do
              (scn ||= Services::Headless::CLI::Option::Parser::Scanner.new op).
                fetch ref, &blk
            end
          )
        end.call
      end
      protected :options
    end.call

    Face::FUN = Face::FN.to_struct

    def subcmd_help cmd  # a hook for the benefit of both child classes & nodes
      cmd.help           # (it corrals help coming in from 2 places, the both
                         # (pre- and postfix forms)
      @argv.length.nonzero? || @queue_a.length.nonzero?
    end

    def additional_usage_lines
      if @sheet.command_tree && has_partially_visible_op
        tos = terminal_option_syntax
        tos and [ "#{ ' ' * usage_header_text.length } #{
          }#{ invocation_string } #{ tos }" ]
      end
    end

    def terminal_option_syntax  # assume @op
      a = each_option.reduce [] do |m, opt|
        m << opt.as_shortest_full_parameter_signifier
      end
      "{#{ a * '|' }}" if a.length.nonzero?
    end

    def option_syntax
      super if ! @sheet.command_tree  # otherwise it just gets in the way
    end

    def argument_syntax
      if @sheet.command_tree
        a = @sheet.command_tree.reduce [] do |m, (_,x)|
          m << x.slug
        end
        if a.length.nonzero?
          "{#{ a * '|' }} [opts] [args]"
        end
      end
    end

    def additional_help y
      a = @sheet.command_tree
      if a
        y << hi( "command#{ 's' if 1 != a.length }:" )
        item_a = a.reduce [] do |row, (_,sheet)|
          node = sheet.hot self, @sheet, nil  # rc, rc_sheet, slug_fragment
          if ! node.slug
            require 'debugger' ; debugger ; 1==1||nil
          end
          row << Item[ node.slug, node.summary ]
        end
        w = item_a.map { |o| o.hdr.length }.reduce 2 do |m, l| m > l ? m : l end
        mar = margin
        fmt = "%#{ w }s#{ mar }"
        item_a.each do |item|
          if ! item.lines || item.lines.length.zero?
            y << "#{ mar }#{ hi( fmt % item.hdr ) } the #{ item.hdr } command"
          else
            y << "#{ mar }#{ hi( fmt % item.hdr ) }#{ item.lines.first }"
            item.lines[ 1 .. -1 ].each do |line|
              y << "#{ mar }#{ fmt % '' }#{ line }"
            end
          end
        end
        y << "Try #{ hi "#{ invocation_string } -h <sub-cmd>" } #{
          }for help on a particular command."
      end
      nil
    end

    def margin
      @parent.margin
    end

    Item = ::Struct.new :hdr, :lines

    def error_stream_yielder  # shadow the location it is called
      @y  # trigger warnings
    end
    public :error_stream_yielder  # #up-delegator

    def initialize request_client, slug_fragment
      super request_client, self.class.story, slug_fragment
    end

    def self.method_added meth  # keep at end!
      @order_a << meth if @order_a  # (the check is just for sing.class & dbg)
      if @do_grab_next_method
        @story.the_method_was_added meth
        @do_grab_next_method = nil
      end
    end
  end

  class CLI
    -> do
      norm_h = {
        0 => -> a, b do
          if b
            [ :set_with_block, b ]
          else
            [ :fetch ]
          end
        end,
        1 => -> a, b do
          if b
            raise ::ArgumentError, "can't have block and args for `version`"
          else
            [ :set_with_arg, a[0] ]
          end
        end
      }
      op_h = {
        set_with_arg: -> arg do
          instance_exec -> { arg }, & op_h[:set_with_block]
        end,
        set_with_block: -> blk do
          if singleton_class.instance_methods( false ).include? :get_version
            raise ::ArgumentError, "won't overwrite existing `get_version`"
          else
            story.add_option VERSION
            define_singleton_method :get_version, &blk
            if ! method_defined? :show_version
              define_method :show_version do
                y = [ ]
                x = invocation_string and y << x
                x = self.class.get_version and y << x
                y.length.nonzero? and @out.puts( y.join( ' ' ) )
                @argv.length.nonzero? || @queue_a.length.nonzero?
                  # stay (keep processing args) if either of these.
              end
              protected :show_version
            end
          end
        end,
        fetch: -> { self.get_version }
      }
      define_singleton_method :version do |*a, &b|
        op, args = norm_h.fetch( a.length )[ a, b ]
        instance_exec( * args, & op_h.fetch( op ) )
      end
    end.call
  end
end
