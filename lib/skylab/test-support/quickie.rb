# (was [#bs-010] poster child before this commit)

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
  #   + arbitrarily deeply nested contexts
  #   + memoized attr_accessors with `let`
  #   + core predicate matchers for `eql`, `match`, `raise_error`,
  #   + the wildcard predicate matcher `be_<foo>` (`be_include`, `be_kind_of`)
  #   + tag filters (only run certain examples tagged a certain way)
  #   + pending examples (contexts?)
  #
  # These are the most salient (to me) features it does *not* ape of RSpec:
  #   + `should_not` (meh)
  #   + run multiple files "at once"
  #   + `before` and `after` blocks
  #   + `specify`
  #   + custom matchers
  #   + ..and pretty much everything else not in the first list!


  # ~ just for fun, below is sometimes defined in a pre-order-ish traversal ~

  # (which is supposed to mean that where possible things in the file
  # are presented in the order there are called during a typical execution,
  # so that if you had a strack trace of each first time a function was
  # called, that is ideally the order they will appear in this file.
  # In theory this should make it more of a narrative story to read top
  # to bottom (and hopefully have your eyes jumping shorter distances)
  # if it's your idea of fun to read the whole thing .. we'll see..)

  Quickie = self  # (for readability and future-proofing)
  TestSupport = ::Skylab::TestSupport  # idem
  MetaHell = ::Skylab::MetaHell  # idem

                                  # when you extend quickie on a module:
  define_singleton_method :extended do |mod|  # #pattern [#sl-111] (sorta)

    if defined? ::RSpec           # NOTE Quickie ever running *must* be
      define_singleton_method :extended do |*| end  # counter-conditional
    else                          # on RSpec even having loaded. i shudder
                                  # at the thought of debugging that.
      ::Kernel.module_exec do
        def should predicate      # define `should` for the whole world
          predicate.match self
        end
      end

      singleton_class.send :remove_method, :extended  # (avoid warnings)

      define_singleton_method :extended do |md|  # once.
        md.extend ModuleMethods
      end
      extended mod                # the money shot
    end
  end

  module Quickie::ModuleMethods   # the story really begins here:

    # pls don't be alarmed - this might as well be called `run` - it's the
    # one true hack in this file - when you say `describe` under an ordinary
    # module that is quickie-enabled, you get this, not a true describe,
    # but something that delegates the describe to a context and then
    # initiates the run sequence on the object graph.  # #todo we might
    # improve this to do whatever rspec does so `descirbe` works as
    # a Kernel method and not just from a Quickie-empowered module.
    # also fix this for multiple files. # #todo

    def describe desc, *rest, &b
      rest.unshift desc
      ctx = ::Class.new Context
      FUN.context_init[ ctx, rest, nil, b ]
      cli = Client.new ctx
      cli.invoke ::ARGV
    end
  end

  class Quickie::Context
    # (note that any names here will collide with user-defined module
    # methods and so on.. so just keep it in mind for now..)

    extend MetaHell::Let::ModuleMethods

    include MetaHell::Let::InstanceMethods

    def self.describe desc, *rest, &b
      context desc, *rest, &b
    end

    def self.description
      @desc.first
    end

    def self.context desc, *rest, &b
      c = ::Class.new self
      rest.unshift desc
      FUN.context_init[ c, rest, @tagset, b ]
      @elements << [ :branch, c ]
      nil
    end

    def self.it desc, *rest, &b
      rest.unshift desc
      @elements << [ :leaf, Quickie::Example.new( self, rest, @tagset, b ) ]
    end

    def self.__quickie_is_pending  # hm..  this ain't even in RSpec..
      @is_pending
    end

    #         ~ instance methods - we try to preserve yr namespace ~

    def __quickie_passed
      @__quickie_runtime.passed
    end

    def __quickie_failed
      @__quickie_runtime.failed
    end

  protected

    def initialize rt
      @__quickie_runtime = rt
    end
  end  # (we will open this up and add more detail below..)

  # `FUN` - especially because we don't want to crowd the namespaces of
  # both a context's class methods and its instance methods, we do certain
  # things with "pure functions" below to get true encapsulation.

  o = { }  # (this turns into `FUN` below)

  o[:context_init] = -> c, desc, inherited_tagset, b do
    c.class_exec do
      @tagset = FUN.tagset[ desc, inherited_tagset ]
      @desc = desc
      @elements = [ ]
      if b
        @is_pending = false
        class_exec(& b )
      else
        @is_pending = true
      end
    end
    nil
  end

  o[:tagset] = -> desc, inherited_tagset do
    tagset = ( desc.pop if ::Hash === desc.last ) # meh
    if inherited_tagset
      if tagset
        tagset = inherited_tagset.merge tagset
      else
        tagset = inherited_tagset
      end
    end
    tagset
  end

  o[:example_producer] = -> ctx_class, branch, leaf do  # i love this
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

  # `Client` - one client is created per test run. It manages user interface,
  # parsing the request to run the tests, creating a test runtime,
  # and initiating the test run on the object graph.

  class Quickie::Client

    def invoke argv
      res = parse_argv argv
      if res
        res = execute
      end
      res
    end

  protected

    def initialize root_context_class
      @root_context_class = root_context_class
      stderr = $stderr
      @y = ::Enumerator::Yielder.new { |line| stderr.puts line }
      @tag_filter = nil
    end

    #         ~ pre-order ~

    def parse_argv argv
      if parse_opts argv
        parse_args argv
      end
    rescue ::OptionParser::ParseError => e
      @y << "#{ e }"
      @y << "try #{ kbd "ruby #{ $PROGRAM_NAME } -h" } for help"
      false
    end

    def kbd x  # (proximity to use)
      stylize x, :green
    end

    def parse_opts argv
      option_parser.parse! argv
      if @or_a
        @tag_filter = -> tag_h { @or_a.detect { |f| f[ tag_h ] } }
      else
        @tag_filter = -> x { true }
      end
      true
    end

    def option_parser
      @option_parser ||= build_option_parser
    end

    def build_option_parser
      o = TestSupport::Services::OptionParser.new
      @or_a = @desc_h = nil
      o.on '-t', '--tag TAG[:VALUE]',
          '(tries to be like the option in rspec)' do |v|
        process_tag_argument v
      end
      o
    end

    tag_rx = /\A(?<not>~)?(?<tag>[^:]+)(?::(?<val>.+))?\z/

    define_method :process_tag_argument do |val|
      md = tag_rx.match val
      if ! md
        raise ::OptionParser::InvalidArgument
      else
        no, tag, val = md.captures
        tag = tag.intern
        val = val ? val.intern : true
        @desc_h ||= { }
        @or_a ||= [ ]
        no, tg, vl = md.captures.zip( [nil, nil, true] ).map { |a, b| a || b }
        ( @desc_h[ no ? :exclude : :include ] ||= [ ] ) << [ tag, val ]
        if no
          @or_a << -> tag_h { ! ( val == tag_h[ tag ] if tag_h ) }
        else
          @or_a << -> tag_h {   ( val == tag_h[ tag ] if tag_h ) }
        end
      end
      nil
    end

    def parse_args argv
      if argv.length.zero? then true else
        raise ::OptionParser::ParseError,
          "unexpected argument#{ s argv.length } - #{ argv[0].inspect }#{
          }#{ ' [..]' if argv.length > 1 }"
      end
    end

    def execute
      branch, leaf, passed, failed, pended, ind, skip, flush =
        build_rendering_functions
      rt = Quickie::Runtime.new passed, failed, pended
      commence  # above `example_producer` call
      producer = FUN.example_producer[ @root_context_class, branch, leaf ]
      @t1 = ::Time.now
      while ex = producer.call
        # puts "#{ ind[] }<<#{ ex.description }>>"
        if @tag_filter[ ex.tagset ]
          if ex.block
            rt.tick_example
            ctx = ex.context.new rt
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
          y << "#{ ind[ depth ] }#{ stylize ctx.description, :yellow }"
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
          y << "#{ ind[ d ] }#{ stylize eg.description, :green }"
        end,
        fail: -> do
          y << "#{ ind[ d ] }#{
            }#{ stylize( "#{ eg.description } (FAILED - #{ ordinal })", :red )}"
        end,
        pend: -> do
          y << "#{ ind[ d ] }#{ stylize "#{ eg.description }", :yellow }"
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
        y << "#{ ind[ d ] }  #{ stylize errmsg, :red }"
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
        # $stderr.puts "#{ ind[ d ] }(#{ eg.description } SKIPPED)"
        eg = nil
      end

      depth = -> { d }

      outer_flush = -> do
        flush[ ] if eg
      end

      outer_indent = -> { ind[ d ] }

      [ branch, leaf, passed, failed, pended, outer_indent, skip, outer_flush ]
    end

    -> do  # `stylize` - map colors to numbers, make strs like "\e[36mhi\e[0m"

      h = -> do
        a = [ nil, :strong, * ::Array.new( 29 ), :red, :green, :yellow,
              :blue, :magenta, :cyan, :white ]
        ::Hash[* a.each_with_index.map { |k, i| [ k, i ] if k }.compact.flatten]
      end.call

      define_method :stylize do |str, *styles|
        "\e[#{ styles.map{ |s| h[s] }.compact.join( ';' ) }m#{ str }\e[0m"
      end  # [#ts-005] - tracking the redundancy of this

    end.call

    def commence
      if @desc_h
        @y << "Run options:#{ render_run_options }\n\n"
      end
      nil
    end

    -> do
      order_a = [ :include, :exclude ].freeze

      define_method :render_run_options do
        a = @desc_h.sort_by do |k, v|
          order_a.index( k ) || order_a.length
        end
        a2 = a.map { |k, v| "#{ k } #{ ::Hash[* v.flatten ].inspect }" }
        1 == a2.length ? " #{ a2.first }" : ( [ '', * a2 ] * "\n  " )
      end
    end.call

    def conclude y, rt
      e, f, p = rt.counts   # total [e]xamples, failed, pending

      if e.zero?
        if @or_a
          y << "All examples were filtered out\n\n"
        else
          y << "No examples found.\n\n"
        end
      end

      y << "\nFinished in #{ ::Time.now - @t1 } seconds"

      if p.nonzero?
        pnd = ", #{ p } pending"
      end

      txt = "#{ e } example#{ s e }, #{ f } failure#{ s f }#{ pnd }"

      y << stylize( txt, (f.nonzero? ? :red : ( p.nonzero? ? :yellow : :green)))

      nil
    end

    def s num
      's' if 1 != num
    end
  end

  class Quickie::Example          # just a simple data-structure for holding
    def description               # e.g. `it` and its block
      @desc.first
    end
    attr_reader :block
    attr_reader :context
    attr_reader :tagset
    def initialize ctx, desc, inherited_tagset, b
      @context = ctx
      @tagset = FUN.tagset[ desc, inherited_tagset ]
      @desc = desc
      @block = b
      @tag_filter = @desc_h = nil
      nil
    end
  end

  class Quickie::Runtime

    def tick_example
      @eg_is_failed = nil
      @eg_count += 1
      nil
    end

    def tick_pending
      @eg_is_failed = nil
      @eg_pending_count += 1
      @emit_pending[ ]
      nil
    end

    def passed msg_func
      @emit_passed[ msg_func ]
      nil
    end

    def failed failmsg
      if ! @eg_is_failed
        @eg_is_failed = true
        @eg_failed_count += 1  # before below (render e.g "(FAILED - 2)")
      end
      @emit_failed[ failmsg, @eg_failed_count ]
      nil
    end

    attr_reader :eg_failed_count

    def counts  # careful
      [ @eg_count, @eg_failed_count, @eg_pending_count ]
    end

  protected

    def initialize emit_passed, emit_failed, emit_pending
      @emit_passed, @emit_failed, @emit_pending =
        emit_passed, emit_failed, emit_pending
      @eg_count = 0
      @eg_failed_count = 0
      @eg_pending_count = 0
      @eg_is_failed = nil
    end
  end

  #         ~ predicates (core) ! (section 2) ~

  class Quickie::Predicate
    class << self
      alias_method :quickie_original_new, :new
    end

    def self.new *args
      kls = ::Class.new self
      kls.class_exec do
        class << self
          alias_method :new, :quickie_original_new
        end
        args.each do |k|
          attr_accessor k
        end
        ivars = args.map{ |x| "@#{ x }".intern }.freeze
        define_singleton_method :ivars do ivars end
      end
      kls
    end

  protected

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
        failed "expected #{ @expected.inspect }, got #{actual.inspect}"
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
      rescue ::StandardError => e
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

  protected

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

  # set phasers to `FUN`

  o[:methify_const] = -> const do # FooBar NCSASpy CrackNCSACode FOO
    const.to_s.gsub( /
     (    (?<= [a-z] )[A-Z] |
          (?<= . ) [A-Z] (?=[a-z]))
     /x ) { "_#{ $1 }" }.downcase.intern
  end

  FUN = ::Struct.new(* o.keys ).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze

  class Quickie::Context  # re-open it
    Quickie::Predicates.constants.each do |const|
      klass = Quickie::Predicates.const_get const, false
      meth = FUN.methify_const[ const ]
      define_method meth do |*expected|
        klass.new @__quickie_runtime, self, *expected
      end
    end
  end

  #         ~ should `be_<foo>( )` method_missing hack (section 3) ~

  class Quickie::Context  # re-open it

    be_rx = /\Abe_(?<be_what>[a-z][_a-z0-9]*)\z/

    define_method :method_missing do |meth, *args, &b|
      md = be_rx.match meth.to_s
      if md
        _be_the_prediate_you_wish_to_see md, args, b
      else
        super meth, *args, &b
      end
    end

    constantize_meth = no_method = msgs = nil

    predicates = Quickie::Predicates ; empty_a = [ ].freeze  # ocd

    define_method :_be_the_prediate_you_wish_to_see do |md, args, b|
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
            no_method[ context, self, actual ]
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
      context.fail "expected #{ insp[ actual ] } to have a #{
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
        fail_msg = -> a, p { "expected #{ insp[a] } #{ neg } #{ insp[ p.expected ] }" }
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
end
