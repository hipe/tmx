module Skylab::TestSupport

  module Quickie  # see [#004] the quickie narrative #intro

    class << self

      def extended mod  # :+[#sl-111] deprecteded `extended` pattern

        self._DEPRECATED__extending_quickie_is_deprecated__use_the_new_method_with_the_much_longer_name
      end

      def enable_kernel_describe

        if ! _do_EKD
          @_do_EKD = true

          if ! ::Kernel.method_defined? :describe  # else just don't mess
            ::Kernel.send :define_method, :describe, ACTIVE_DESC_METHOD___
          end
        end
        NIL_
      end
    end  # >>

if false  # :#here-1

      def __say_multiple_describes
        "quickie note - if you want to have multiple root-level #{
            }`describe`s aggregated into one test run, you should try #{
            }the undocumented, experimental recursive test runner. running #{
            }them individually."
      end

    class Context__  # (will re-open)

      # (both instance- & singleton method namespaces of this are userland!)

      class << self

        def describe desc, * rest, & p
          context desc, * rest, & p
        end

        def description
          @desc_a.fetch( 0 ) if @desc_a.length.nonzero?  # e.g
        end

        def context * desc_a, & p
          cls = ::Class.new self
          Init_context__[ cls, desc_a, @tagset_h, p ]
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
      end  # >>

      def initialize rt
        @__quickie_runtime = rt  # NOTE ivar must be used in this file only!
      end

      def quickie_fail_with_message_by & msg_p

        # (experimental hack to allow custom matchers in both q & r.s)

        @__quickie_runtime._failed_by( & msg_p )
        UNABLE_
      end

      # Home_::Let[ self ]
    end

    class Tagset__

      def initialize * a
        @ts_h, @lineno = a
      end

      attr_reader :lineno

      def [] sym
        @ts_h && @ts_h[ sym ]
      end
    end

    # <- (net: -1) #open [#036]

  Init_context__ = -> c, desc_a, inherited_tagset, p do
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
    NIL_
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

  Build_example_stream_proc_ = -> ctx_class, branch, leaf do  # i love this
    stack = [ ] ; cur = ctx_class
    push = -> do
      els = cur.instance_variable_get :@elements
      branch[ stack.length, cur ]
      stack.push els.reverse  # even if empty!
      NIL_
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

      Rewrite_digit_switches___ = -> do

        # an experimental semi-hack: "expand" head-anchored digit-looking
        # switches to become [etc]. anchored to head so we don't parse an
        # argument for another option (unlike [#br-074]). the platform o.p
        # is not sympathetic to causes like this at all.

        rx = /\A-(?<lineno>\d+)\z/
        -> argv do
          md = rx.match argv.first  # nil item IFF empty ary
          if md
            argv_ = []
            begin
              argv.shift
              argv_.push '--line', md[ :lineno ]
              md = rx.match argv.first  # nil item IFF empty ary
              md ? redo : break
            end while nil
            argv_.concat argv
            argv.replace argv_ ; nil
          end
        end
      end.call

      def __init_tag_filter_proc

        @_tag_filter_p = if @_OR_p_a
          or_p_a = @_OR_p_a
          -> tagset do
            or_p_a.detect do | p |
              p[ tagset ]
            end
          end
        else
          MONADIC_TRUTH_
        end
        NIL_
      end

      def __parse_args argv

        if argv.length.zero?
          ACHIEVED_
        else
          @_info_yielder << __say_argv( argv )
          _invite
          UNABLE_
        end
      end

      def __say_argv argv
        "unexpected argument#{ s argv.length }: #{ argv[0].inspect }#{
          }#{ ' [..]' if argv.length > 1 }"
      end

      def _invite

        _program_name = [
          ::File.basename( @_program_name_s_a.first ),
          * @_program_name_s_a[ 1 .. -1 ] ].join SPACE_

        @_info_yielder << "try #{ kbd "ruby #{ _program_name } -h" } for help"

        NIL_
      end

    Stylize__ = -> do  # #open :[#005]. #[#ze-023.2] the stylize diaspora
      h = ::Hash[ %i| red green yellow blue magenta cyan white |.
        each_with_index.map do |i, d| [ i, 31 + d ] end ]
      h[ :strong ] = 1 ; p = h.method :fetch
      -> i, s do
        "\e[#{ p[ i ] }m#{ s }\e[0m"
      end
    end.call

    define_method :kbd, & Stylize__.curry[ :green ]

    def __build_option_parser

      _lib = Home_::Library_

      _lib || Home_._SANITY  # #todo - catch when "stowaways" breaks in this way, early

      o = _lib::OptionParser.new

      o.on '-t', '--tag TAG[:VALUE]',
          '(tries to be like the option in rspec)' do |v|
        __tags_receiver.receive_tag_argument v
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

    def __tags_receiver
      @___tags_receiver ||= ___build_tags_receiver
    end

    def ___build_tags_receiver

      Tags_Receiver_.new(

        :on_error, -> s do
          e = ::OptionParser::InvalidArgument.new
          e.reason = s
          raise e
        end,

        :on_info_qualified_knownness, method( :add_tag_description ),

        :on_filter_proc, method( :_receive_OR_proc ) )
    end

    def add_tag_description include_or_exclude_i, tag_i, val_x
      @tag_desc_h ||= {}
      ( @tag_desc_h[ include_or_exclude_i ] ||= [] ).push [ tag_i, val_x ]
      @did_add_render_tag_run_options ||= begin
        _add_run_option_renderer( & method( :render_tag_run_options ) )
        true
      end ; nil
    end

    def process_line_argument s
      accept_line_argument _convert_line_argument s
    end

    def accept_line_argument d

      @___did_init_line_set ||= ___init_line_set
      @_line_set << d ; nil
    end

    def ___init_line_set

      _will_OR_reduce_by do |tagset|
        @_line_set.include? tagset.lineno
      end

      _add_run_option_renderer do |y|
        @_line_set.each do |d|
          y << "--line #{ d }"
        end
      end

      require 'set'
      @_line_set = ::Set.new
      ACHIEVED_
    end

    def process_min_line_argument s
      accept_min_line_argument _convert_line_argument s
    end

    def process_max_line_argument s
      accept_max_line_argument _convert_line_argument s
    end

    def _convert_line_argument s

      if LINE_RX__ =~ s
        s.to_i
      else
        @_info_yielder << __say_not_valid_line_argument( s )
        raise ::OptionParser::InvalidArgument
      end
    end

    LINE_RX__ = /\A\d+\z/

    def __say_not_valid_line_argument s
      "(not a valid line number, expecting integer - #{ s.inspect })"
    end

    def accept_min_line_argument d

      _will_OR_reduce_by do |tagset|
        d <= tagset.lineno
      end

      _add_run_option_renderer do |y|
        y << "--from #{ d }"
      end
      NIL_
    end

    def accept_max_line_argument d

      _will_OR_reduce_by do |tagset|
        d >= tagset.lineno
      end

      _add_run_option_renderer do |y|
        y << "--to #{ d }"
      end
      NIL_
    end

    def execute_
      branch, leaf, passed, failed, pended, skip, flush =
        build_rendering_functions
      rt = Runtime__.new passed, failed, pended
      commence
      next_example = ___build_example_stream_proc branch, leaf
      @t1 = ::Time.now
      begin
        eg = next_example.call
        eg or break
        # puts "#{ indent[] }<<#{ eg.description }>>"
        if @_tag_filter_p[ eg.tagset ]
          if eg.block
            rt.tick_example
            ctx = eg.context.new rt
            if eg.has_before_each
              eg.run_before_each ctx
            end
            ctx.instance_exec( & eg.block )
          else
            rt.tick_pending
          end
        else
          skip[]
        end
        redo
      end while nil
      flush[]
      conclude @_info_yielder, rt
      NIL_
    end

    def ___build_example_stream_proc branch, leaf
      if @_example_stream_p_p
        @_example_stream_p_p[ branch, leaf ]
      else
        Build_example_stream_proc_[ @root_context_class, branch, leaf ]
      end
    end

    def build_rendering_functions  # #storypoint-465

      tab = '  ' ; y = @_info_yielder ; d = eg = ordinal = nil  # `depth`, `example`

      state = :pass  # the first example, even w/ no tests, still is 'pass'

      indent = -> depth { tab * depth }  # indent

      render_branch = -> depth, ctx do
        if ctx.__quickie_is_pending  # experimental non-rspec feature
          y << "#{ indent[ depth ] }#{ stylize :yellow, ctx.description }"
        else
          y << "#{ indent[ depth ] }#{ ctx.description }"
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
        NIL_
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
          y << "#{ indent[ d ] }#{ stylize :green, eg.description }"
        end,
        fail: -> do
          y << "#{ indent[ d ] }#{
            }#{ stylize :red, "#{ eg.description } (FAILED - #{ ordinal })" }"
        end,
        pend: -> do
          y << "#{ indent[ d ] }#{ stylize :yellow, "#{ eg.description }" }"
        end
      }

      flush = -> do
        flush_branches[ ]
        flush_h.fetch( state )[ ]
        state = :pass  # (examples with no tests still pass)
        eg = nil  # (don't ever clear `d` we use it after flush)
      end

      passed = -> & msg_p do  # (maybe if verbose, success msg:)
        state = :pass  # important, ofc
        # flush[] if eg  # NOTE this might mixed-color results if .. etc
        # y << "#{ indent[ d + 1 ] }<<#{ msg_func[] }>>"
      end

      failed = -> ord, & errmsg_p do

        ordinal = ord
        state = :fail

        if eg
          flush[]
        end

        y << "#{ indent[ d ] }  #{ stylize :red, errmsg_p[] }"
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
        # Home_.lib_.stderr.puts "#{ indent[ d ] }(#{ eg.description } SKIPPED)"
        eg = nil
      end

      outer_flush = -> do
        flush[ ] if eg
      end

      [ branch, leaf, passed, failed, pended, skip, outer_flush ]
    end

    define_method :stylize, & Stylize__

    def commence
      if @_run_option_p_a
        @_info_yielder << "Run options:#{ render_run_options }#{ NEWLINE_ }#{ NEWLINE_ }"
      end
      NIL_
    end

    def render_run_options
      y = []
      @_run_option_p_a.each do |p|
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
        if @_OR_p_a
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

      NIL_
    end

    def s num
      's' if 1 != num
    end
    # -> (net: 0)

end  # if false (#here-1)

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

      def initialize passed_p, failed_p, pended_p
        @_eg_count = 0
        @eg_failed_count = 0
        @_eg_pending_count = 0
        @_eg_is_failed = nil
        @_emit_failed = failed_p
        @_emit_passed = passed_p
        @_emit_pending = pended_p
      end

      # ~ writers

      def tick_example
        @_eg_is_failed = nil
        @_eg_count += 1 ;  nil
      end

      def tick_pending
        @_eg_is_failed = nil
        @_eg_pending_count += 1
        @_emit_pending[ ] ; nil
      end

      def __passed_by & msg_p
        @_emit_passed[ & msg_p ]
        :_quickie_passed_
      end

      def _failed_by & msg_p

        # (it's possible for one example to fail several times)

        if ! @_eg_is_failed
          @_eg_is_failed = true
          @eg_failed_count += 1  # before below (render e.g "(FAILED - 2)")
        end

        @_emit_failed[ @eg_failed_count, & msg_p ]

        UNABLE_
      end

      # ~ readers

      def counts  # careful
        [ @_eg_count, @eg_failed_count, @_eg_pending_count ]
      end

      attr_reader :eg_failed_count
    end

    # -- facet 1 - predicates (core)

    class Predicate__

      class << self

        alias_method :quickie_original_new, :new

        def new *args, &p

          ::Class.new( self ).class_exec do

            class << self
              alias_method :new, :quickie_original_new
            end

            define_singleton_method :ivars, ( -> do
              sym_a = args.map do |sym|
                attr_accessor sym
                :"@#{ sym }"
              end.freeze
              -> { sym_a }
            end ).call

            p and class_exec( & p )

            self
          end
        end
      end  # >>

      def initialize * a
        @runtime, @context, * rest = a
        ivars = self.class.ivars
        rest.each_with_index do |x, d|
          instance_variable_set ivars.fetch( d ), x
        end
      end

      def _pass_by & msg_p

        @runtime.__passed_by( & msg_p )
      end

      def _fail_by & msg_p

        @runtime._failed_by( & msg_p )
      end
    end

    Predicates__ = ::Module.new  # filled with joy, sadness

    # `eql` (as in "should eql(..)") -

    class Predicates__::Eql < Predicate__.new :expected

      def matches? actual

        if @expected == actual

          _pass_by do
            "equals #{ @expected.inspect }"
          end
        else

          _fail_by do
            "expected #{ @expected.inspect }, got #{ actual.inspect }"
          end
        end
      end
    end

    # `match` (as in "should match( /.../ )") -

    class Predicates__::Match < Predicate__.new :expected

      def matches? actual

        if @expected =~ actual
          _pass_by do
            "matches #{ @expected.inspect }"
          end
        else

          _fail_by do
            "expected #{ @expected.inspect }, had #{ actual.inspect }"
          end
        end
      end
    end

    class Predicates__::RaiseError < Predicate__.new :expected_class, :message_rx

      def initialize runtime, context, *a  # ick [class] ( regex | string )

        a_ = [ ( a.shift if ::Class === a.first ) ]
        case a.first
        when ::Regexp
          a_.push a.shift
        when ::String
          a_.push %r{\A#{ ::Regexp.escape a.shift }\z}
        else
          a_.push nil
        end

        if a.length.nonzero? || a_.length.zero?
          raise ::ArgumentError, ___say( a )
        end

        super runtime, context, * a_
      end

      def ___say a
        "expecting [class], ( regexp | string ), near: #{ a.first.inspect }"
      end

      def matches? actual
        begin
          actual.call
        rescue ::StandardError, ::ScriptError => e
        end
        ok = e || ___did_not_raise
        ok &&= @expected_class ? __check_class( e ) : true
        ok &&= @message_rx ? __check_message( e ) : true
        ok and __pass e
      end

      def ___did_not_raise
        _fail_by { "expected lambda to raise, didn't raise anything." }
      end

      def __check_class e
        if e.kind_of? @expected_class
          ACHIEVED_
        else
          _fail_by do
            "expected #{ @expected_class }, had #{ e.class }"
          end
        end
      end

      def __check_message e
        if @message_rx =~ e.message
          ACHIEVED_
        else
          _fail_by do
            "expected #{ e.message } to match #{ @message_rx }"
          end
        end
      end

      def __pass _e
        _pass_by do
          "raises #{ @expected_class } matching #{ @message_rx }"
        end
      end
    end

    # <- (net: -1)

  # for each const in the predicates module (each of which must be a
  # predicate class) define the corresponding context instance method

  Methify_const__ = -> const do  # FooBar NCSASpy CrackNCSACode FOO  # #todo - use [cb] name
    const.to_s.gsub( /
     (    (?<= [a-z] )[A-Z] |
          (?<= . ) [A-Z] (?=[a-z]))
     /x ) { "_#{ $1 }" }.downcase.intern
  end

  class Context__  # re-open
    Predicates__.constants.each do |const|
      cls = Predicates__.const_get const, false
      meth = Methify_const__[ const ]
      define_method meth do |*expected|
        cls.new @__quickie_runtime, self, *expected
      end
    end
  end

  # -> (net: 0)

    # -- facet 2 - should `be_<foo>()` method_missing hack

    class Context__  # re-open

      def method_missing meth, * args, & p

        md = BE_RX___.match meth.to_s
        if md
          ___be_the_predicate_you_wish_to_see md, args, p
        else
          super meth, *args, &p
        end
      end

      BE_RX___ = /\Abe_(?<be_what>[a-z][_a-z0-9]*)\z/

      def ___be_the_predicate_you_wish_to_see md, args, p

        const = Constantize_method___[ md.string ]

        _cls = if Predicates__.const_defined? const, false
          Predicates__.const_get const, false
        else
          ___build_predicate_dynamically_eew const, md, args, p
        end

        _cls.new @__quickie_runtime, self, * args
      end

      def ___build_predicate_dynamically_eew const, md, args, p

        attr_a = []

        takes_args = args.length.nonzero?   # #sketchy - etc
        if takes_args
          attr_a.push :expected
        end

        cls = ::Class.new Predicate__.new( * attr_a )
        Predicates__.const_set const, cls

        define_method = cls.method :define_method

        _p = if takes_args
          -> do
            [ @expected ]
          end
        else
          -> do
            EMPTY_A_
          end
        end

        define_method.call :args, & _p

        be_what = md[ :be_what ]

        m = "#{ be_what }?".intern

        define_method.call :expected_method_name do
          m
        end

        pass_msg, fail_msg = Messages___[ be_what, takes_args ]

        define_method.call :matches? do | actual |

          if actual.respond_to? m

            matchdata = actual.send m, * self.args
            if matchdata
              _pass_by do
                pass_msg[ actual, self ]
              end
              matchdata
            else
              _fail_by do
                fail_msg[ actual, self ]
              end
            end
          else
            No_Method___[ @context, self, actual ]
          end
        end
        cls
      end

      Constantize_method___ = -> meth do # foo_bar !ncsa_spy !crack_ncsa_code foo
        meth.to_s.gsub( /(?:^|_)([a-z])/ ) { $1.upcase }.intern
      end

      insp = nil

      No_Method___ = -> context, predicate, actual do
        fail "expected #{ insp[ actual ] } to have a #{
          }`#{ predicate.expected_method_name }` method"
        NIL_
      end

      insp = -> x do # yeah..
        str = x.inspect
        str.length > 80 ? x.class.to_s : str  # WHATEVER
      end

      omfg_h = nil

      Messages___ = -> be_what, takes_args do
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

    # -- facet 3 - before hooks

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
      end  # >>
    end

    BEFORE_H__ = { each: :bfr_each, all: :bfr_all }.freeze

    class Example__
      def has_before_each
        @context.const_defined? :BEFORE_EACH_PROC_
      end
      def run_before_each ctx  # assume `has_before_each`
        ctx.instance_exec( & @context::BEFORE_EACH_PROC_ )
        NIL_
      end
    end

    # --

    class << self
      def apply_experimental_specify_hack test_context_class
        Here_::Actors_::Specify.apply_if_not_defined test_context_class
      end
    end

    # <- (net: -1)

    # ~ :+#protected-API

  class Tags_Receiver_  # (used by performers too)

    def initialize * x_a
      @send_error_p = @send_info_qualified_knownness_p = @send_filter_proc_p =
      @send_pass_filter_proc_p = @send_no_pass_filter_proc_p = nil
      d = -1 ; last = x_a.length - 1
      while d < last
        sym = x_a.fetch d += 1
        md = RX__.match sym
        md or raise ::ArgumentError, sym
        ivar = :"@send_#{ md[ 0 ] }_p"
        instance_variable_get( ivar ).nil? or raise ::ArgumentError, sym
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
      if @send_info_qualified_knownness_p
        x = @send_info_qualified_knownness_p[ yes ? :include : :exclude, tag_i, val_x ]
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
# -> (net: 0)

    module Plugins  # ..
      Autoloader_[ self, :boxxy ]
    end

    Here_ = self
  end
end
# :#tombstone-A.1: the previous: ( service, main run loop, rendering
#   functions, "runtime" (now "statistics"), `do_not_invoke!` )
