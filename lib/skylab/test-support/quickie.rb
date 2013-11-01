module Skylab::TestSupport::Quickie

  # Quickie is an attempt at a minimal drop-in ersatz for the simplest/
  # most frequently used 80% of RSpec, but one that is supposed to take
  # scant milliseconds to load and (depending on your tests) run one file.
  # It tries to hold itself to the "swallow rule" - that the time it takes
  # to load and start running one file (or changeset) of tests should not
  # take longer than the time it takes you to swallow.
  #
  # It is not a replacement for RSpec (depening on how you use RSpec),
  # it is just a means to an end of writing RSpec-compatible tests that
  # can run much faster during development provided that you want to run
  # only 1 file and are doing something "simple" (for various definitions
  # of that) in that file.

  # RSpec-like features it *does* include include:
  #   + arbitrarily deeply nested contexts (can define class methods, i.m's).
  #   + memoized attr_accessors with `let` (that nest appropriately)
  #   + core predicate matchers for `eql`, `match`, `raise_error`,
  #     (by design the predicates are added only to the test context, not
  #      to Kernel, so the places you can make your assertions are limited.)
  #   + the wildcard predicate matcher `be_<foo>` (`be_include`, `be_kind_of`)
  #   + tag filters (only run certain examples tagged a certain way)
  #   + pending examples (and contexts! unlike r.s)
  #   + limited, experimental support for non-nested before( :each )
  #
  # These are the most salient (to the author) features of RSpec that
  # quickie offers limited or NO support for:
  #   + `should_not` (meh)
  #   + run multiple files "at once" - experimental recursive runner exists
  #   + `before` and `after` blocks - limited support per above
  #   + `specify` (but experiments in the universe exist at [#017])
  #   + custom matchers - except for the `be_<foo>` wildcard per above
  #   + ..and pretty much everything else not in the first list!
  #
  # Strange behaviors (features not bugs!):
  #
  #   + Quickie has the exception matcher (should raise_error(..)) that tries
  #     to work just like r.s, but beyond this: **Quickie does not use
  #     exceptions internally to indicate a test failure.**  2 corollaries
  #     follow from this:
  #     1) when there are multiple tests (`x.should eql(y)`)
  #     in one example (`it "..." { }`), the first failing test will not
  #     automatically halt further processing of the example (in contrast to
  #     r.s).
  #     2) Quickie makes no effort to rescue any exceptions, so any that are
  #     unhandled during test execution bubble all the way out and probably
  #     halt the execution of subsequent tests. it is the way of simplicity.
  #   + As hinted at above, Quickie finds it just as easy to mark an
  #     entire context as pending (because it has no block) as it does
  #     for an example, so this is something it does that ::RSpec does not do.
  #     Arguably this can be a nice enhancement to flow, when you know you
  #     are going to make a node a context rather than an example, but you
  #     want to just jot it down and pend it.
  #     (::Rspec lets such nodes exist, it just does not report them, hence
  #     cross-compatibility is not broken, it's just that one way is better.)


  # ~ just for fun, below is sometimes defined in a pre-order-ish traversal ~

  # (which is supposed to mean that where possible things in the file
  # are presented in the order they are called during a typical execution,
  # so that if you had a stack trace of each first time a function was
  # called, that is ideally the order they will appear in this file.
  # In theory this should make it more of a narrative story to read top
  # to bottom (and hopefully have your eyes jumping shorter distances)
  # if it's your idea of fun to read the whole thing .. we'll see..)

  MetaHell = ::Skylab::MetaHell   # (for readability)
  Quickie = self                  # (for readability and future-proofing)
  TestSupport = ::Skylab::TestSupport  # idem

  service = nil                   # (here for scope, defined below)

                                  # one way to hook into quickie is this:
                                  # when you extend quickie on to a module
  define_singleton_method :extended do |mod|  # #pattern [#sl-111] (sorta)

    singleton_class.send :remove_method, :extended  # redefine it below..

                                  # it's going to rustle the service
    if service[].quickie_has_reign  # only contort modules if no ::RSpec!
      define_singleton_method :extended do |md|  # redefine this selfsame method
        md.extend ModuleMethods   # just to show that we are serious -
      end                         # this gets our m.m in its singleton ancestor
      extended mod                # then (gulp) call self with this new
    else
      define_singleton_method :extended do |*| end  # otherwise to show that we
                                  # are serious about *not* doing quickie
    end                           # (b.c e.g ::RSpec is loaded)
  end                             # NOTE Quickie ever running *must* be
                                  # counter-conditional on ::RSpec even having
                                  # loaded! i shudder at the thought of
                                  # debugging that.

                                  # so what is this `service` metioned above?
  service = -> do                 # it is a true service, it gets memoized
    svc = Quickie::Service.
      new nil, TestSupport::Stdout_[], TestSupport::Stderr_[]
    svc.listen                    # and everything (but it could be tested
    service = -> { svc }          # in isolation)
    svc
  end

  define_singleton_method :service do service.call end

  class Quickie::Service          # ( re-opens as necessary for narrative )

    def initialize _, o, e
      @paystream, @infostream = o, e
      @default_info_stream_line_proc = -> line { @infostream.puts line }
      @info_stream_line_proc_is_default = nil
      self.info_stream_line_proc = nil  # see
      @invoke_is_enabled = true ; @did_resolve_invoke = false
      @is_listening = false
      @has_seen_one = nil  # to trigger the warning about this not yet impl.
      @kernel_describe_is_enabled = nil
      @client = nil
      nil
    end

    def listen
      @is_listening and raise ::RuntimeError, "service is already listening."
      @is_listening = true        # state machine-esque
      if (( @quickie_has_reign = ! defined? ::RSpec ))
        ::Kernel.module_exec do
          def should predicate    # define `should` for the whole world
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

  # the story really begins from a `describe` that is from some sort
  # of non-context, like a quickie-empowered module (empowering revealed above):

  module Quickie::ModuleMethods
    def describe desc, *rest, &p  # (same as 1 below)
      m, a = Quickie.service.resolve_describe desc, *rest, &p
      m.receiver.send m.name, *a
    end
  end

  # (or from anywhere, if this hack is turned on #experimental (and we break
  # the narrative for aesthetics sorry)

  def self.enable_kernel_describe
    Quickie.service.enable_kernel_describe
  end

  class Quickie::Service

    def enable_kernel_describe
      if ! @kernel_describe_is_enabled
        @kernel_describe_is_enabled = true
        if ::Kernel.method_defined? :describe then nil else  # just don't mess
          ::Kernel.module_exec do
            def describe desc, *rest, &p  # (same as 1 above)
              m, a = Quickie.service.resolve_describe desc, *rest, &p
              m.receiver.send m.name, *a
            end
          end
          nil
        end
      end
    end

    def resolve_describe first_desc_line, * desc_a, &p
      desc_a.unshift first_desc_line
      ctx = ::Class.new Quickie::Context       # 1 desc always == 1 context
      Context_init__[ ctx, desc_a, nil, p ]
      if @client
        r = @client.add_context_class_and_resolve ctx
      else
        cli = Client.new @y, ctx
        touch_multiple_describes cli
        if @invoke_is_enabled
          @did_resolve_invoke = true
          r = cli.resolve_invoke ::ARGV
        end
      end
      r || Noop__[]
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

  class Quickie::Context

    # (note that any names here will collide with user-defined module
    # methods and so on.. so just keep it in mind for now..)

    extend MetaHell::Let::ModuleMethods

    include MetaHell::Let::InstanceMethods

    def self.describe desc, *rest, &p
      context desc, *rest, &p
    end

    def self.description
      @desc_a.fetch( 0 ) if @desc_a.length.nonzero?  # e.g
    end

    def self.context *desc_a, &p
      c = ::Class.new self
      Context_init__[ c, desc_a, @tagset_h, p ]
      @elements << [ :branch, c ]
      nil
    end

    def self.it desc, * a, & p
      @elements << [ :leaf, Quickie::Example.new( self, a.unshift( desc ),
        Tagset__.new( Build_tagset_h__[ a, @tagset_h ],
          caller_locations( 1, 1 )[ 0 ].lineno ), p ) ] ; nil
    end

    def self.__quickie_is_pending
      @is_pending
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
  end  # (re-opened below)

  class Tagset__
    def initialize ts_h, lineno
      @lineno = lineno ; @ts_h = ts_h ; nil
    end
    attr_reader :lineno
    def [] i
      @ts_h && @ts_h[ i ]
    end
  end

  Noop__ = -> do
    MetaHell::EMPTY_P_.method :call
    # ( distinct from the empty proc, noop must be a bound method )
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

  Example_producer__ = -> ctx_class, branch, leaf do  # i love this
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

  class Quickie::Client  # one client is creted per test run. it manages
    # UI, parsing the request to run the tests, creating a test runtime,
    # and initiating the test run on the object graph.

    def initialize y, root_context_class
      @tag_desc_h = @example_producer_p = @line_set = @or_p_a = nil
      @root_context_class = root_context_class
      @tag_filter_p = nil ; @y = y
    end

    attr_writer :tag_filter_p, :example_producer_p  # #hacks-only

    def resolve_invoke argv
      ok = parse_argv argv  # totally absorbed on success
      if ok
        method :execute
      else
        Noop__[]
      end
    end

    def puts line  # ( svc wants this )
      @y << line
    end

  private

    #         ~ pre-order ~

    def parse_argv argv
      if parse_opts argv
        parse_args argv
      end
    rescue TestSupport::Services::OptionParser::ParseError => e
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

  private

    Stylize__ = -> do  # the stylize diaspora :[#005] of [#hl-029]
      h = ::Hash[ %i| red green yellow blue magenta cyan white |.
        each_with_index.map do |i, d| [ i, 31 + d ] end ]
      h[ :strong ] = 1 ; p = h.method :fetch
      -> i, s do
        "\e[#{ p[ i ] }m#{ s }\e[0m"
      end
    end.call

    define_method :kbd, & Stylize__.curry[ :green ]
    private :kbd

    def parse_opts argv
      option_parser.parse! argv
      @tag_filter_p and fail "sanity - optparse and tag filter are mutex"
      if @or_p_a
        @tag_filter_p = -> tagset { @or_p_a.detect { |p| p[ tagset ] } }
      else
        @tag_filter_p = MetaHell::MONADIC_TRUTH_
      end
      true
    end

    def option_parser
      @option_parser ||= build_option_parser
    end

    def build_option_parser
      o = TestSupport::Services::OptionParser.new
      o.on '-t', '--tag TAG[:VALUE]',
          '(tries to be like the option in rspec)' do |v|
        process_tag_argument v
      end
      o.on '-l', '--line NUMBER', '(experiment)' do |v|
        process_line_argument v
      end
      o
    end

    def process_tag_argument val
      md = TAG_RX__.match val
      if ! md
        raise ::OptionParser::InvalidArgument
      else
        accept_tag_argument md
      end
    end
    TAG_RX__ = /\A(?<not>~)?(?<tag>[^:]+)(?::(?<val>.+))?\z/

    def accept_tag_argument md
      no, tag_s, val_s = md.captures
      tag_i = tag_s.intern
      val_x = val_s ? val_s.intern : true
      @or_p_a ||= [ ] ; @tag_desc_h ||= { }
      ( @tag_desc_h[ no ? :exclude : :include ] ||= [ ] ) << [ tag_i, val_x ]
      if no
        @or_p_a << -> tagset { val_x != tagset[ tag_i ] }
      else
        @or_p_a << -> tagset { val_x == tagset[ tag_i ] }
      end ; nil
    end

    def process_line_argument s
      if LINE_RX__ !~ s
        @y << "(not a valid line number, expecting integer - #{ s.inspect })"
        raise ::OptionParser::InvalidArgument
      else
        accept_line_argument s.to_i
      end
    end
    LINE_RX__ = /\A\d+\z/

    def accept_line_argument d
      @line_set ||= (( begin
        (( @or_p_a ||= [] )) << -> tagset do
          @line_set.include? tagset.lineno
        end
        require 'set' ; ::Set.new
      end )) << d ; nil
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
      rt = Quickie::Runtime.new passed, failed, pended
      commence
      producer = get_producer branch, leaf
      @t1 = ::Time.now
      while ex = producer.call
        # puts "#{ ind[] }<<#{ ex.description }>>"
        if @tag_filter_p[ ex.tagset ]
          if ex.block
            rt.tick_example
            ctx = ex.context.new rt
            ex.has_before_each and ex.run_before_each ctx
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
        Example_producer__[ @root_context_class, branch, leaf ]
      end
    end

    # `build_rendering_functions` - this is kind of derky mostly because
    # we jump through hoops to accomplish two behaviors: 1) render the
    # name of the example in the right color, yet do that before you render
    # the constituent test(s) inside it that made it fail 2) don't render
    # surrounding context description names for nodes in the tree that
    # you skipped.. (and it's the weirdest way to do a collection of
    # "view templates" that i've ever seen/done.)

    def build_rendering_functions
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
          bindex = depth   # (ofc) and one that is at a higher level than
        end                # the last branch we rendered, so if we end up
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
        flush[] if eg  # now it's safe to emit it
        y << "#{ ind[ d ] }  #{ stylize :red, errmsg }"
      end

      pended = -> do
        state = :pend
        flush[] if eg  # now we certainly want to emit
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
        # Stderr_[].puts "#{ ind[ d ] }(#{ eg.description } SKIPPED)"
        eg = nil
      end

      outer_flush = -> do
        flush[ ] if eg
      end

      [ branch, leaf, passed, failed, pended, skip, outer_flush ]
    end

    define_method :stylize, & Stylize__
    private :stylize

    def commence
      if @tag_desc_h || @line_set
        @y << "Run options:#{ render_run_options }\n\n"
      end
      nil
    end

    def render_run_options  # (eew)
      y = []
      @tag_desc_h and render_tag_run_options y
      @line_set and render_line_run_options y
      if 1 == y.length
        " #{ y[ 0 ] }"
      else
        [ '', * y ] * "\n  "
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

    def render_line_run_options y
      @line_set.each do |d| y << "--line #{ d }" end ; nil
    end

    def conclude y, rt
      e, f, p = rt.counts   # total [e]xamples, failed, pending

      if e.zero?
        if @or_p_a
          y << "All examples were filtered out"
        else
          y << "No examples found.\n\n"  # <- trying to look like r.s there
        end
      end

      y << "\nFinished in #{ ::Time.now - @t1 } seconds"

      if p.nonzero?
        pnd = ", #{ p } pending"
      end

      txt = "#{ e } example#{ s e }, #{ f } failure#{ s f }#{ pnd }"

      y << stylize( f.zero? ? p.zero? ? :green : :yellow : :red, txt )

      nil
    end

    def s num
      's' if 1 != num
    end
  end

  class Quickie::Example  # just a simple data-structure for holding e.g
    # `it` and its block

    def initialize ctx, desc, tagset, p
      @block = p ; @context = ctx ; @desc = desc ; @tagset = tagset ; nil
    end

    attr_reader :block, :context, :tagset

    def description
      @desc.first
    end
  end

  class Quickie::Runtime

    def initialize emit_passed, emit_failed, emit_pending
      @emit_passed, @emit_failed, @emit_pending =
        emit_passed, emit_failed, emit_pending
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

  #         ~ facet 1 - predicates (core) ! ~

  class Quickie::Predicate

    class << self
      alias_method :quickie_original_new, :new
    end

    def self.new *args, &p
      ::Class.new( self ).class_exec do
        class << self
          alias_method :new, :quickie_original_new
        end
        args.each do |k|
          attr_accessor k
        end
        ivars = args.map{ |x| "@#{ x }".intern }.freeze
        define_singleton_method :ivars do ivars end
        p and class_exec( & p )
        self
      end
    end

  private

    def initialize runtime, context, *rest
      @runtime = runtime
      @context = context
      ivars = self.class.ivars
      rest.each_with_index do |x, i|
        instance_variable_set ivars.fetch( i ), x  # implicitly validates
      end
    end

    def passed msg_func
      @runtime.passed msg_func
    end

    def failed msg
      @runtime.failed msg
    end
  end

  module Quickie::Predicates
    # fill it with joy, fill it with sadness
  end

  # `eql` (as in "should eql(..)") -

  class Quickie::Predicates::Eql < Quickie::Predicate.new :expected
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

  class Quickie::Predicates::Match < Quickie::Predicate.new :expected
    def match actual
      if @expected =~ actual
        passed -> { "matches #{ @expected.inspect }" }
      else
        failed "expected #{ @expected.inspect }, had #{ actual.inspect }"
      end
      nil
    end
  end

  class Quickie::Predicates::RaiseError <
    Quickie::Predicate.new :expected_class, :message_rx

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

  #         ~ please excuse me while i do this WONDERHACK ~

  # for each object that is currently a constant set under Predicates,
  # (which, each one is expected to be a predicate class), define the
  # corresponding instance method for contexts omgz

  Methify_const__ = -> const do # FooBar NCSASpy CrackNCSACode FOO
    const.to_s.gsub( /
     (    (?<= [a-z] )[A-Z] |
          (?<= . ) [A-Z] (?=[a-z]))
     /x ) { "_#{ $1 }" }.downcase.intern
  end

  class Quickie::Context  # re-open it
    Quickie::Predicates.constants.each do |const|
      klass = Quickie::Predicates.const_get const, false
      meth = Methify_const__[ const ]
      define_method meth do |*expected|
        klass.new @__quickie_runtime, self, *expected
      end
    end
  end

  #         ~ facet 2 - should `be_<foo>( )` method_missing hack ~

  class Quickie::Context  # re-open it

    be_rx = /\Abe_(?<be_what>[a-z][_a-z0-9]*)\z/

    define_method :method_missing do |meth, *args, &p|
      md = be_rx.match meth.to_s
      if md
        _be_the_prediate_you_wish_to_see md, args, p
      else
        super meth, *args, &p
      end
    end

    constantize_meth = no_method = msgs = nil

    predicates = Quickie::Predicates ; empty_a = [ ].freeze  # ocd

    define_method :_be_the_prediate_you_wish_to_see do |md, args, p|
      const = constantize_meth[ md.string ]
      if predicates.const_defined? const, false
        klass = predicates.const_get const, false
      else
        takes_args = args.length.nonzero?   # #sketchy - etc
        attr_a = [ ]
        attr_a << :expected if takes_args
        klass = predicates.const_set const,
          ::Class.new( Quickie::Predicate.new(* attr_a ) )
        class << klass
          public :define_method
        end
        klass.define_method :args, & (
          if ! takes_args then -> { empty_a } else
            -> { [ @expected ] }
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
        stem = be_what.gsub '_', ' '
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

  #                       ~ facet 3 - before hooks ~

  Quickie::BEFORE_H_ = { each: :before_each, all: :before_all }.freeze

  class Quickie::Context
    def self.before i, &blk
      send Quickie::BEFORE_H_[ i ], blk
    end
    def self.before_each blk
      const_defined?( :BEFORE_EACH_PROC_ ) and raise "sorry - in the #{
        }intereset of simplicity there is not yet support for nested #{
        }before( :each | :all ) blocks.."
      const_set :BEFORE_EACH_PROC_, blk
      nil
    end
    def self.before_all blk
      before_each -> do
        if blk
          blk.call
          blk = nil  # so dirty yet so pure
        end
        nil
      end
    end
  end

  class Quickie::Example
    def has_before_each
      @context.const_defined? :BEFORE_EACH_PROC_
    end
    def run_before_each ctx  # assume `has_before_each`
      ctx.instance_exec( & @context::BEFORE_EACH_PROC_ )
      nil
    end
  end

  #                    ~ facet N - extrinsic API for hacks ~

  #  ~ facet N.1 - `do_not_invoke!`

  # `Quickie.do_not_invoke` - prevents quickie from flushing its tests.
  # for hacks e.g in your test file. might make noise.

  def self.do_not_invoke!
    service.do_not_invoke!
  end

  class Quickie::Service  # #re-open for section N.1
    def do_not_invoke!
      me = "`#{ self.class }.do_not_invoke!`"
      if @invoke_is_enabled
        if @did_resolve_invoke
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

  class Quickie::Service
    def run
      @run ||= Quickie::Run_.new self
    end
    attr_reader :paystream, :infostream
    def attach_client_notify client
      @client and fail "sanity - client is already attached"
      @client = client
      nil
    end
  end
end
