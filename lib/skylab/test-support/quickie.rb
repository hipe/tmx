module Skylab::TestSupport

  module Quickie  # see [#004] the quickie narrative #intro

    class << self

      def extended mod  # #storypoint-10, :+[#sl-111]~

        singleton_class.send :remove_method, :extended

        if _service_instance.quickie_has_reign
          define_singleton_method :extended do |mod_|
            mod_.extend Module_Methods__ ; nil
          end
          extended mod
        else
          define_singleton_method :extended do |*| end ; nil
        end
      end

      define_method :_service_instance, -> do  # #storypoint-25

        p = -> do
          lib = TestSupport_.lib_
          x = Service__.new nil, lib.stdout, lib.stderr
          x.listen
          p = -> { x }
          x
        end

        -> { p[] }

      end.call
    end

    # while #open [#036] indentation will jump uglyly: older
    # code is one level back, correct it as you refactor it

  class Service__

    def initialize _, o, e
      @paystream = o ; @infostream = e
      @default_info_stream_line_proc = -> line { @infostream.puts line }
      @info_stream_line_proc_is_default = nil
      self.info_stream_line_proc = nil  # see
      @invoke_is_enabled = true ; @did_produce_invoke = false
      @is_listening = false
      @has_seen_one = nil  # to trigger the warning about this not yet impl.
      @kernel_describe_is_enabled = nil
      @client = nil
      nil
    end

    def listen
      @is_listening and raise ::RuntimeError, "service is already listening."
      @is_listening = true  # state machine-esque
      if (( @quickie_has_reign = ! defined? ::RSpec ))
        ::Kernel.module_exec do
          def should predicate  # define `should` for the whole world
            predicate.match self
          end
        end
      end
      nil
    end

    attr_reader :quickie_has_reign

    def info_stream_line_proc= p
      if p
        if @info_stream_line_proc_is_default
          @y = ::Enumerator::Yielder.new( & p )
        else
          @y << "(#{ self.class } won't override custom #{
            }`info_stream_line_proc` - set it to nil first"
        end
      elsif @info_stream_line_proc_is_default
        @y << "(#{ self.class } - error line proc is already default.)"
      else
        @info_stream_line_proc_is_default = true  # brusque, brash
        self.info_stream_line_proc = @default_info_stream_line_proc
      end
      p
    end
  end

    # the story really begins from a `describe` that is from some sort of non-
    # context, like a quickie-empowered module like we made above

    DESCRIBE_METHOD__ = -> s, * a, & p do
      bm = Quickie_._service_instance.produce_describe_bound_method s, * a, & p
      bm.receiver.send bm.name
    end

    module Module_Methods__
      define_method :describe, DESCRIBE_METHOD__
    end

    # or you can use `describe` from anywhere with this #experimental hack

    class << self
      def enable_kernel_describe
        _service_instance.enable_kernel_describe
      end
    end

    class Service__

      def enable_kernel_describe
        do_enable_kernel_describe if ! @kernel_describe_is_enabled
      end

      private def do_enable_kernel_describe
        @kernel_describe_is_enabled = true
        if ! ::Kernel.method_defined? :describe  # else just don't mes
          ::Kernel.send :define_method, :describe, DESCRIBE_METHOD__ ; nil
        end
      end

    def produce_describe_bound_method first_desc_line, * desc_a, &p
      desc_a.unshift first_desc_line
      ctx = ::Class.new Context__  # 1 desc always == 1 context
      Context_init__[ ctx, desc_a, nil, p ]
      if @client
        x = @client.add_context_class_and_resolve ctx
      else
        cli = Client_.new @y, ctx
        touch_multiple_describes cli
        if @invoke_is_enabled
          @did_produce_invoke = true
          x = cli.produce_invoke_method ::ARGV
        end
      end
      x || EMPTY_P_.method( :call )
    end

    def touch_multiple_describes cli
      if @has_seen_one
        # until [#ts-008] one root `describe` gets you one real-time
        # invocation.
        cli.puts "quickie note - if you want to have multiple root-level #{
          }`describe`s aggregated into one test run, you should try #{
          }the undocumented, experimental recursive test runner. running #{
          }them individually."
      else
        @has_seen_one = true
      end
      nil
    end
    end

    class Context__

      # the instance, singleton method namespaces are ultimately userland

      class << self

        def describe desc, * rest, & p
          context desc, * rest, & p
        end

        def description
          @desc_a.fetch( 0 ) if @desc_a.length.nonzero?  # e.g
        end

        def context * desc_a, & p
          cls = ::Class.new self
          Context_init__[ cls, desc_a, @tagset_h, p ]
          @elements.push [ :branch, cls ] ; nil
        end

        def it desc, * a, & p
          @elements.push [ :leaf, Example__.new( self, a.unshift( desc ),
            Tagset__.new( Build_tagset_h__[ a, @tagset_h ],
              caller_locations( 1, 1 )[ 0 ].lineno ), p ) ] ; nil
        end

        def __quickie_is_pending
          @is_pending
        end
      end

      def initialize rt
        @__quickie_runtime = rt
      end

      def __quickie_passed
        @__quickie_runtime.passed
      end

      def __quickie_failed
        @__quickie_runtime.failed
      end

      TestSupport_::Let[ self ]

    end  # will re-open below

    class Tagset__
      def initialize * a
        @ts_h, @lineno = a
      end
      attr_reader :lineno
      def [] i
        @ts_h && @ts_h[ i ]
      end
    end

  Context_init__ = -> c, desc_a, inherited_tagset, p do
    c.class_exec do
      @tagset_h = Build_tagset_h__[ desc_a, inherited_tagset ]
      @desc_a = desc_a
      @elements = [ ]
      if p
        @is_pending = false
        class_exec( & p )
      else
        @is_pending = true
      end
    end
    nil
  end

  Build_tagset_h__ = -> desc, inherited_tagset_h do
    tagset_h = ( desc.pop if ::Hash === desc.last ) # meh
    if inherited_tagset_h
      if tagset_h
        tagset_h = inherited_tagset_h.merge tagset_h
      else
        tagset_h = inherited_tagset_h
      end
    end
    tagset_h
  end

  Example_producer_ = -> ctx_class, branch, leaf do  # i love this
    stack = [ ] ; cur = ctx_class
    push = -> do
      els = cur.instance_variable_get :@elements
      branch[ stack.length, cur ]
      stack.push els.reverse  # even if empty!
      nil
    end
    push[]
    what = nil  # scope
    poptop = -> do
      while stack.length.nonzero? && stack.last.length.zero?
        stack.pop
      end
      if stack.length.nonzero?
        which, cur = stack.last.pop
        what.fetch( which ).call
      end
    end
    what = {
      branch: -> do
        push[]
        poptop[]
      end,
      leaf: -> do
        leaf[ stack.length, cur ]
        cur
      end
    }
    poptop
  end

  class Client_  # #storypoint-285

    def initialize y, root_context_class
      @at_end_of_run_p_a = nil
      @tag_desc_h = @example_producer_p = @line_set = @or_p_a = nil
      @run_option_p_a = nil
      @root_context_class = root_context_class
      @tag_filter_p = nil ; @y = y
    end

    attr_writer :example_producer_p, :tag_filter_p  # #hacks-only

    def produce_invoke_method argv
      ok = parse_argv argv  # totally absorbed on success
      if ok
        method :execute
      else
        EMPTY_P_.method :call
      end
    end

    def puts line  # ( svc wants this )
      @y << line
    end

  private

    #  ~ (in narrative pre-order)

    def parse_argv argv
      if parse_opts argv
        parse_args argv
      end
    rescue Library_::OptionParser::ParseError => e
      usage_and_invite "#{ e }"
      nil
    end

  public

    def usage_and_invite msg
      msg and @y << msg
      invite
      nil
    end

    def invite
      @y << "try #{ kbd "ruby #{ program_name } -h" } for help" ; nil
    end

    def program_name
      @program_name ||= ::File.basename( $PROGRAM_NAME )
    end

    def at_end_of_run &p
      ( @at_end_of_run_p_a ||= [] ).push p ; nil
    end

  private

    Stylize__ = -> do  # #open :[#005] :+[#hl-029] the stylize diaspora
      h = ::Hash[ %i| red green yellow blue magenta cyan white |.
        each_with_index.map do |i, d| [ i, 31 + d ] end ]
      h[ :strong ] = 1 ; p = h.method :fetch
      -> i, s do
        "\e[#{ p[ i ] }m#{ s }\e[0m"
      end
    end.call

    define_method :kbd, & Stylize__.curry[ :green ]

    def parse_opts argv
      option_parser.parse! argv
      @tag_filter_p and fail "sanity - optparse and tag filter are mutex"
      if @or_p_a
        @tag_filter_p = -> tagset { @or_p_a.detect { |p| p[ tagset ] } }
      else
        @tag_filter_p = MONADIC_TRUTH_
      end
      true
    end

    def option_parser
      @option_parser ||= build_option_parser
    end

    def build_option_parser
      o = Library_::OptionParser.new
      o.on '-t', '--tag TAG[:VALUE]',
          '(tries to be like the option in rspec)' do |v|
        tag_shell.receive_tag_argument v
      end
      o.on '--line NUMBER', "run the example whose line number equals this" do |v|
        process_line_argument v
      end
      o.on '--from NUMBER', "run the examples whose line number is >= this" do |v|
        process_min_line_argument v
      end
      o.on '--to NUMBER', "run the examples whose line number is <= this" do |v|
        process_max_line_argument v
      end
      o
    end

    def tag_shell
      @tag_shell ||= bld_tag_shell
    end

    def bld_tag_shell

      Tag_Shell_.new(

        :on_error, -> s do
          e = ::OptionParser::InvalidArgument.new
          e.reason = s
          raise e
        end,

        :on_info_trio, method( :add_tag_description ),

        :on_filter_proc, method( :add_or_p ) )
    end

    def add_tag_description include_or_exclude_i, tag_i, val_x
      @tag_desc_h ||= {}
      ( @tag_desc_h[ include_or_exclude_i ] ||= [] ).push [ tag_i, val_x ]
      @did_add_render_tag_run_options ||= begin
        add_run_option_renderer( & method( :render_tag_run_options ) )
        true
      end ; nil
    end

    def add_or_p p
      (( @or_p_a ||= [] )) << p ; nil
    end

    def add_run_option_renderer & p
      ( @run_option_p_a ||= [] ) << p ; nil
    end

    def process_line_argument s
      accept_line_argument cnvrt_line_argument s
    end

    def cnvrt_line_argument s
      if LINE_RX__ =~ s
        s.to_i
      else
        @y << "(not a valid line number, expecting integer - #{ s.inspect })"
        raise ::OptionParser::InvalidArgument
      end
    end
    LINE_RX__ = /\A\d+\z/

    def accept_line_argument d
      @did_add_line_set_p ||= begin
        add_or_p -> tagset do
          @line_set.include? tagset.lineno
        end
        require 'set'
        @line_set = ::Set.new
        add_run_option_renderer do |y|
          @line_set.each do |d_| y << "--line #{ d_ }" end
        end
        true
      end
      @line_set << d ; nil
    end

    def process_min_line_argument s
      accept_min_line_argument cnvrt_line_argument s
    end

    def process_max_line_argument s
      accept_max_line_argument cnvrt_line_argument s
    end

    def accept_min_line_argument d
      add_or_p -> tagset do
        d <= tagset.lineno
      end
      add_run_option_renderer do |y|
        y << "--from #{ d }"
      end ; nil
    end

    def accept_max_line_argument d
      add_or_p -> tagset do
        d >= tagset.lineno
      end
      add_run_option_renderer do |y|
        y << "--to #{ d }"
      end ; nil
    end

    def parse_args argv
      if argv.length.zero? then true else
        raise ::OptionParser::ParseError,
          "unexpected argument#{ s argv.length } - #{ argv[0].inspect }#{
          }#{ ' [..]' if argv.length > 1 }"
      end
    end

    def execute
      branch, leaf, passed, failed, pended, skip, flush =
        build_rendering_functions
      rt = Runtime__.new passed, failed, pended
      commence
      producer = get_producer branch, leaf
      @t1 = ::Time.now
      while ex = producer.call
        # puts "#{ ind[] }<<#{ ex.description }>>"
        if @tag_filter_p[ ex.tagset ]
          if ex.block
            rt.tick_example
            ctx = ex.context.new rt
            if ex.has_before_each
              ex.run_before_each ctx
            end
            ctx.instance_exec(& ex.block )
          else
            rt.tick_pending
          end
        else
          skip[]
        end
      end
      flush[]
      conclude @y, rt
      nil
    end

    def get_producer branch, leaf
      if @example_producer_p
        @example_producer_p[ branch, leaf ]
      else
        Example_producer_[ @root_context_class, branch, leaf ]
      end
    end

    def build_rendering_functions  # #storypoint-465
      tab = '  ' ; y = @y ; d = eg = ordinal = nil  # `depth`, `example`

      state = :pass  # the first example, even w/ no tests, still is 'pass'

      ind = -> depth { tab * depth }  # indent

      render_branch = -> depth, ctx do
        if ctx.__quickie_is_pending  # experimental non-rspec feature
          y << "#{ ind[ depth ] }#{ stylize :yellow, ctx.description }"
        else
          y << "#{ ind[ depth ] }#{ ctx.description }"
        end
      end

      bcache = [ ]  # cache of each most recent branch at that depth.
      bindex = 0    # range of index to start rendering at of above

      cache_branch = -> depth, ctx do
        if depth < bindex  # this is a branch that both we haven't seen yet
          bindex = depth  # (ofc) and one that is at a higher level than
        end  # the last branch we rendered, so if we end up
        # flushing the branches, be sure to include this one
        bcache[ depth ] = ctx
        nil
      end

      flush_branches = -> do
        ( bindex ... d ).each do |depth|
          render_branch[ depth, bcache.fetch( depth ) ]
        end
        bindex = d  # in the future, only render branches at this depth or >
        # unless we see a new branch that is <, then change it
      end

      flush_h = {
        pass: -> do
          y << "#{ ind[ d ] }#{ stylize :green, eg.description }"
        end,
        fail: -> do
          y << "#{ ind[ d ] }#{
            }#{ stylize :red, "#{ eg.description } (FAILED - #{ ordinal })" }"
        end,
        pend: -> do
          y << "#{ ind[ d ] }#{ stylize :yellow, "#{ eg.description }" }"
        end
      }

      flush = -> do
        flush_branches[ ]
        flush_h.fetch( state )[ ]
        state = :pass  # (examples with no tests still pass)
        eg = nil  # (don't ever clear `d` we use it after flush)
      end

      passed = -> msg_func do  # (maybe if verbose, success msg:)
        state = :pass  # important, ofc
        # flush[] if eg  # NOTE this might mixed-color results if .. etc
        # y << "#{ ind[ d + 1 ] }<<#{ msg_func[] }>>"
      end

      failed = -> errmsg, ord do
        state = :fail
        flush[] if eg  # now it's safe to call_digraph_listeners it
        y << "#{ ind[ d ] }  #{ stylize :red, errmsg }"
      end

      pended = -> do
        state = :pend
        flush[] if eg  # now we certainly want to call_digraph_listeners
      end

      branch = -> depth, ctx do   # render a description or context heading
        flush[] if eg
        if ctx.__quickie_is_pending  # experimental non-rspec thing
          d = depth
          flush_branches[ ]
          render_branch[ depth, ctx ]
        else
          cache_branch[ depth, ctx ] # do this and comment out below line
          # render_branch[ depth, ctx ]  # or do this and comment out above line
        end
      end

      leaf = -> depth, example do  # called when we *begin* an example
        flush[] if eg
        eg = example ; d = depth
      end

      skip = -> do
        # LIB_.stderr.puts "#{ ind[ d ] }(#{ eg.description } SKIPPED)"
        eg = nil
      end

      outer_flush = -> do
        flush[ ] if eg
      end

      [ branch, leaf, passed, failed, pended, skip, outer_flush ]
    end

    define_method :stylize, & Stylize__

    def commence
      if @run_option_p_a
        @y << "Run options:#{ render_run_options }#{ NEWLINE_ }#{ NEWLINE_ }"
      end
      nil
    end

    def render_run_options
      y = []
      @run_option_p_a.each do |p|
        p[ y ]
      end
      if 1 == y.length
        " #{ y[ 0 ] }"
      else
        [ EMPTY_S_, * y ] * "#{ NEWLINE_ } "
      end
    end

    def render_tag_run_options y
      _a = @tag_desc_h.sort_by do |k, v|
        ORDER_A__.index( k ) || ORDER_A__.length
      end
      _a.each do |k, v|
        y << "#{ k } #{ ::Hash[* v.flatten ].inspect }"
      end ; nil
    end
    #
    ORDER_A__ = [ :include, :exclude ].freeze

    def conclude y, rt
      e, f, p = rt.counts   # total [e]xamples, failed, pending

      if e.zero?
        if @or_p_a
          y << "All examples were filtered out"
        else
          y << "No examples found.#{ NEWLINE_ }#{ NEWLINE_ }"  # <- trying to look like r.s there
        end
      end

      y << "\nFinished in #{ ::Time.now - @t1 } seconds"

      if p.nonzero?
        pnd = ", #{ p } pending"
      end

      txt = "#{ e } example#{ s e }, #{ f } failure#{ s f }#{ pnd }"

      y << stylize( f.zero? ? p.zero? ? :green : :yellow : :red, txt )

      @at_end_of_run_p_a and @at_end_of_run_p_a.each( & :call )

      nil
    end

    def s num
      's' if 1 != num
    end
  end

    class Example__  # simple data structure for holding e.g `it` and its block

      def initialize * a
        @context, @desc, @tagset, @block = a
      end

      attr_reader :block, :context, :tagset

      def description
        @desc.first
      end
    end

  class Runtime__

    def initialize * a
      @emit_passed, @emit_failed, @emit_pending = a
      @eg_count = 0
      @eg_failed_count = 0
      @eg_pending_count = 0
      @eg_is_failed = nil
    end

    attr_reader :eg_failed_count

    def counts  # careful
      [ @eg_count, @eg_failed_count, @eg_pending_count ]
    end

    def tick_example
      @eg_is_failed = nil
      @eg_count += 1 ;  nil
    end

    def tick_pending
      @eg_is_failed = nil
      @eg_pending_count += 1
      @emit_pending[ ] ; nil
    end

    def passed msg_func
      @emit_passed[ msg_func ] ; nil
    end

    def failed failmsg
      if ! @eg_is_failed
        @eg_is_failed = true
        @eg_failed_count += 1  # before below (render e.g "(FAILED - 2)")
      end
      @emit_failed[ failmsg, @eg_failed_count ] ; nil
    end
  end

    #  ~ facet 1 - predicates (core) !

    class Predicate__

      class << self

        alias_method :quickie_original_new, :new

        def new *args, &p

          ::Class.new( self ).class_exec do

            class << self
              alias_method :new, :quickie_original_new
            end

            define_singleton_method :ivars, ( -> do
              i_a = args.map do |i|
                attr_accessor i
                :"@#{ i }"
              end.freeze
              -> { i_a }
            end ).call

            p and class_exec( & p )

            self
          end
        end
      end

    private

      def initialize * a
        @runtime, @context, * rest = a
        ivars = self.class.ivars
        rest.each_with_index do |x, d|
          instance_variable_set ivars.fetch( d ), x
        end
      end

      def passed msg_p
        @runtime.passed msg_p
      end

      def failed msg_p
        @runtime.failed msg_p
      end
    end

    Predicates__ = ::Module.new  # filled with joy, sadness

  # `eql` (as in "should eql(..)") -

  class Predicates__::Eql < Predicate__.new :expected
    def match actual
      if @expected == actual
        passed -> { "equals #{ @expected.inspect }" }
      else
        failed "expected #{ @expected.inspect }, got #{ actual.inspect }"
      end
      nil
    end
  end

  # `match` (as in "should match( /.../ )") -

  class Predicates__::Match < Predicate__.new :expected
    def match actual
      if @expected =~ actual
        passed -> { "matches #{ @expected.inspect }" }
      else
        failed "expected #{ @expected.inspect }, had #{ actual.inspect }"
      end
      nil
    end
  end

  class Predicates__::RaiseError < Predicate__.new :expected_class, :message_rx

    def match actual
      begin
        actual.call
      rescue ::StandardError, ::ScriptError => e
      end
      if ! e
        failed "expected lambda to raise, didn't raise anything."
      else
        ok = true
        if @expected_class
          if ! e.kind_of?( @expected_class )
            ok = false
            failed "expected #{ @expected_class }, had #{ e.class }"
          end
        end
        if ok && @message_rx
          if @message_rx !~ e.message
            ok = false
            failed "expected #{ e.message } to match #{ @message_rx }"
          end
        end
        if ok
          passed -> do
            "raises #{ @expected_class } matching #{ @message_rx }"
          end
        end
      end
      nil
    end

  private

    # ick [class] ( regex | string )

    def initialize runtime, context, *a
      use_a = []
      use_a << ( ( ::Class === a.first ) ? a.shift : nil )
      if ::Regexp === a.first
        use_a << a.shift
      elsif ::String === a.first
        use_a << %r{\A#{ ::Regexp.escape a.shift }\z}
      else
        use_a << nil
      end
      if a.length.nonzero? || use_a.length.zero?
        raise ::ArgumentError, "expecting [class], ( regexp | string ), #{
          }near: #{ a.first.inspect }"
      end
      super runtime, context, * use_a
    end
  end

  # for each const in the predicates module (each of which must be a
  # predicate class) define the corresponding context instance method

  Methify_const__ = -> const do  # FooBar NCSASpy CrackNCSACode FOO  # #todo - use [cb] name
    const.to_s.gsub( /
     (    (?<= [a-z] )[A-Z] |
          (?<= . ) [A-Z] (?=[a-z]))
     /x ) { "_#{ $1 }" }.downcase.intern
  end

  class Context__  # re-open it
    Predicates__.constants.each do |const|
      klass = Predicates__.const_get const, false
      meth = Methify_const__[ const ]
      define_method meth do |*expected|
        klass.new @__quickie_runtime, self, *expected
      end
    end
  end

  #  ~ facet 2 - should `be_<foo>( )` method_missing hack

  class Context__  # re-open

    be_rx = /\Abe_(?<be_what>[a-z][_a-z0-9]*)\z/

    define_method :method_missing do |meth, *args, &p|
      md = be_rx.match meth.to_s
      if md
        _be_the_predicate_you_wish_to_see md, args, p
      else
        super meth, *args, &p
      end
    end

    constantize_meth = no_method = msgs = nil

    predicates = Predicates__

    define_method :_be_the_predicate_you_wish_to_see do |md, args, p|
      const = constantize_meth[ md.string ]
      if predicates.const_defined? const, false
        klass = predicates.const_get const, false
      else
        takes_args = args.length.nonzero?   # #sketchy - etc
        attr_a = [ ]
        attr_a << :expected if takes_args
        klass = predicates.const_set const,
          ::Class.new( Predicate__.new(* attr_a ) )
        class << klass
          public :define_method
        end
        klass.define_method :args, & (
          if takes_args
            -> { [ @expected ] }
          else
            -> { EMPTY_A_ }
          end )
        meth = "#{ md[:be_what] }?".intern
        klass.define_method :expected_method_name do meth end
        pass_msg, fail_msg = msgs[ md[:be_what], takes_args ]
        klass.define_method :match do |actual|
          if actual.respond_to? meth
            if actual.send meth, * self.args
              passed -> { pass_msg[ actual, self ] }
            else
              failed fail_msg[ actual, self ]
            end
          else
            no_method[ @context, self, actual ]
          end
        end
      end
      klass.new @__quickie_runtime, self, * args
    end

    constantize_meth = -> meth do # foo_bar !ncsa_spy !crack_ncsa_code foo
      meth.to_s.gsub( /(?:^|_)([a-z])/ ) { $1.upcase }.intern
    end

    insp = nil

    no_method = -> context, predicate, actual do
      fail "expected #{ insp[ actual ] } to have a #{
        }`#{ predicate.expected_method_name }` method"
      nil
    end

    insp = -> x do # yeah..
      str = x.inspect
      str.length > 80 ? x.class.to_s : str  # WHATEVER
    end

    omfg_h = nil

    msgs = -> be_what, takes_args do
      pos, neg = omfg_h.fetch be_what.intern do |k|
        stem = be_what.gsub UNDERSCORE_, SPACE_
        [ "is #{ stem }", "to be #{ stem }" ]
      end
      if takes_args
        pass_msg = -> a, p { "#{ pos } #{ insp[ p.expected ] }" }
        fail_msg = -> a, p { "expected #{ insp[a] } #{ neg } #{
                               }#{ insp[ p.expected ] }" }
      else
        pass_msg = -> a, p { pos.dup }
        fail_msg = -> a, p { "expected #{ insp[a] } #{ neg }" }
      end
      [pass_msg, fail_msg]
    end

    omfg_h = {
      kind_of: [ "is kind of", "to be kind of" ],
      include: [ "includes", "to include" ],
      nil:     [ "is nil", "to be nil" ]
    }
  end

    #  ~ facet 3 - before hooks

    class Context__
      class << self
        def before which_i, & p
          send BEFORE_H__.fetch( which_i ), p
        end
      private
        def bfr_all p
          p_ = -> do
            p.call  # LOOK you get NO text context - maybe diff than rspec
            p_ = EMPTY_P_
          end
          bfr_each -> do  # so dirty yet so pure
            p_[]
          end
        end
        def bfr_each p
          const_defined?( :BEFORE_EACH_PROC_ ) and raise say_no_nested_before
          const_set :BEFORE_EACH_PROC_, p ; nil
        end
        def say_no_nested_before
          "sorry - in the intereset of simplicity there is not yet #{
           }support for nested before( :each | :all ) blocks.."
        end
      end
    end

    BEFORE_H__ = { each: :bfr_each, all: :bfr_all }.freeze

    class Example__
      def has_before_each
        @context.const_defined? :BEFORE_EACH_PROC_
      end
      def run_before_each ctx  # assume `has_before_each`
        ctx.instance_exec( & @context::BEFORE_EACH_PROC_ )
        nil
      end
    end

    #  ~ facet N - extrinsic API for hacks

    #  ~ facet N.1 - `do_not_invoke!`

    # `Quickie.do_not_invoke` - prevents quickie from flushing its tests.
    # for hacks e.g in your test file. might make noise.

    class << self
      def do_not_invoke!
        _service_instance.do_not_invoke!
      end
    end

  class Service__  # #re-open for section N.1
    def do_not_invoke!
      me = "`#{ self.class }.do_not_invoke!`"
      if @invoke_is_enabled
        if @did_produce_invoke
          @y << "(#{ me } called after a `describe` block has already #{
            }finished - call it earlier if it does not work as expected.)"
        else
          @y << "(#{ me } called - won't run tests.)"
        end
        @invoke_is_enabled = false
      else
        @y << "(#{ me } already called?)"
      end
      nil
    end
  end

    #  ~ facet N.2 - the runner experiment ~

    class << self
      def active_session
        _service_instance.active_sssn  # name convention [#bs-028.D]
      end
    end

  class Service__
    def active_sssn
      @front ||= bld_front
    end
  private
    def bld_front
      Quickie::Front__.new self
    end
  public
    def attach_client_notify client
      @client and fail "sanity - client is already attached"
      @client = client ; nil
    end
    attr_reader :paystream, :infostream
  end

    #  ~ N.3

    class << self
      def apply_experimental_specify_hack test_context_class
        Quickie_::Specify__.apply_if_not_defined test_context_class
      end
    end

    # ~ :+#protected-API

  class Tag_Shell_

    def initialize * x_a
      @send_error_p = @send_info_trio_p = @send_filter_proc_p =
      @send_pass_filter_proc_p = @send_no_pass_filter_proc_p = nil
      d = -1 ; last = x_a.length - 1
      while d < last
        i = x_a.fetch d += 1
        md = RX__.match i
        md or raise ::ArgumentError, i
        ivar = :"@send_#{ md[ 0 ] }_p"
        instance_variable_get( ivar ).nil? or raise ::ArgumentError, i
        instance_variable_set ivar, x_a.fetch( d += 1 )
      end
      @send_error_p ||= ev { raise ::ArgumentError, "#{ ev }" }
      freeze
    end

    RX__ = /(?<=\A on_ )[_a-z]+\z/x

    def receive_tag_argument s

      md = TAG_RX___.match s

      if md
        no, tag_s, val_s = md.captures

        _yes = ! no
        _tag_i = tag_s.intern
        _val_x = val_s ? val_s.intern : true

        build_and_send_tag_byproducts_via_three_parts _yes, _tag_i, _val_x
      else

        @send_error_p[ "invalid tag expression: \"#{ s }\"" ]
      end
    end

    TAG_RX___ = /\A
      (?<not> ~ )?
      (?<tag> [-a-zA-Z_0-9]+ )  # or whatever
      (?: : (?<val> .+) )?
    \z/x

  private
    def build_and_send_tag_byproducts_via_three_parts yes, tag_i, val_x
      if @send_info_trio_p
        x = @send_info_trio_p[ yes ? :include : :exclude, tag_i, val_x ]
      end
      if yes
        p = -> tagset do
          val_x == tagset[ tag_i ]
        end
        @send_pass_filter_proc_p and x = @send_pass_filter_proc_p[ p ]
      else
        p = -> tagset do
          val_x != tagset[ tag_i ]
        end
        @send_no_pass_filter_proc_p and x = @send_no_pass_filter_proc_p[ p ]
      end
      @send_filter_proc_p and x = @send_filter_proc_p[ p ]
      x
    end
  end

    Quickie_ = self
  end
end
