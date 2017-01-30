module Skylab::TestSupport

  module Quickie  # see [#004] the quickie narrative #intro

    class << self

      # (these are the things that can't/shouldn't be covered)

      def enable_kernel_describe
        self._COVERED_BUT_NOT_INTEGRATED
      end

      def extended mod  # :+[#sl-111] deprecteded `extended` pattern
        self._DEPRECATED__extending_quickie_is_deprecated__use_the_new_method_with_the_much_longer_name
      end

      def enhance_test_support_module_with_the_method_called_describe mod
        _runtime.__enhance_test_support_module_with_the_method_called_describe mod
        NIL
      end

      def _runtime
        send @_runtime
      end

      def __runtime_initially
        @__runtime = Runtime___.define do |o|
          o.kernel_module = ::Kernel
          o.toplevel_module = ::Object
        end
        @_runtime = :__runtime
        send @_runtime
      end

      def __runtime
        @__runtime  # hi.
      end
    end  # >>

    @_runtime = :__runtime_initially

    # === the "SERVICE" ===

    class Runtime___ < Common_::SimpleModel

      # responsibility: represent the surrounding platform "runtime" to
      # the inner quickie (er) runtime.
      #
      # also: manage the memoization of the all-important quickie service.

      def initialize
        yield self
        @_quickie_has_reign = :__determine_if_quickie_has_reign
        @_enhance = :__enhance_a_module_for_the_first_time_ever
        @_read_quickie_service = :__QUICKIE_SERVICE_IS_NOT_STARTED
        @_touch_quickie_service = :__start_quickie_service_autonomously
        @_write_quickie_service = :__write_quickie_service_once
      end

      attr_writer(
        :kernel_module,
        :toplevel_module,
      )

      # -- "kernel describe" (not used often, but available to look like r.s)

      def __enable_kernel_describe
        if @kernel_module.method_defined? :describe
          NOTHING_  # hi. assume r.s
        else
          me = self
          @kernel_module.send :define_method, :describe do |*desc_s_a, &p|
            svc = me._touch_quickie_service
            if svc
              _hm = svc._receive_describe p, desc_s_a
              _hm  # #todo
            end
          end
        end
        NIL
      end

      # -- the more common way to tap into quickie:

      def __enhance_test_support_module_with_the_method_called_describe mod
        send @_enhance, mod
      end

      def __enhance_a_module_for_the_first_time_ever mod

        remove_instance_variable :@_enhance

        if send @_quickie_has_reign
          svc = _touch_quickie_service
          if svc
            __when_quickie_has_reign svc
          else
            __when_service_failed_to_start
          end
        else
          __when_quickie_does_not_have_reign
        end

        send @_enhance, mod
      end

      def __when_service_failed_to_start

        # service failed to start (maybe ARGV issues). define `describe` anyway

        @_definition_for_the_method_called_describe = -> * do
          self._COVER_ME
          NOTHING_  #  SUPER risky - you better hope..
        end

        @_enhance = :_enhance_normally
      end

      def __when_quickie_does_not_have_reign

        # r.s is loaded probably. expect that r.s has defined `define`.
        # do nothing now and subsequently.

        @_enhance = :__do_nothing_because_some_other_test_service_is_in_charge
      end

      def __when_quickie_has_reign svc

        # service started and there is no r.s loaded. is "normal"

        @_definition_for_the_method_called_describe = -> * desc_s_a, & p do
          svc._receive_describe p, desc_s_a
        end
        @_enhance = :_enhance_normally
      end

      def __do_nothing_because_some_other_test_service_is_in_charge _mod
        NOTHING_  # hi. probably r.s is driving
      end

      def _enhance_normally mod
        mod.send :define_singleton_method, :describe,
          @_definition_for_the_method_called_describe
        NIL
      end

      # -- how the quickie service is normally started:

      def _touch_quickie_service
        send @_touch_quickie_service
      end

      def __start_quickie_service_autonomously

        # when single test is loaded thru `ruby -w` in terminal, probably

        start_quickie_service_ ::ARGV, $stdin, $stdout, $stderr, [ $PROGRAM_NAME ]
      end

      def start_quickie_service_ * five
        svc = __build_quickie_service_via_standard_five five
        _write_first_and_only_service svc
        svc
      end

      def receive_API_call__ p, x_a
        client = Here_::API::API_InjectedClient_via_Listener_and_Arguments[ p, x_a ]
        svc = ( client and _build_quickie_service_via_injected_client client )
        _write_first_and_only_service svc
        client and client.RECEIVE_RUNTIME__ self
      end

      def _write_first_and_only_service svc
        send @_write_quickie_service, svc  # even if false-ish
        NIL
      end

      def __build_quickie_service_via_standard_five five
        client = CLI_InjectedClient_via_StandardFive___[ five ]
        client and _build_quickie_service_via_injected_client client
      end

      def _build_quickie_service_via_injected_client client
        Service_via_InjectedClient__.new client, @kernel_module
      end

      def __write_quickie_service_once svc
        @_write_quickie_service = :__QUICKIE_SERVICE_IS_ALREADY_RUNNING
        @_read_quickie_service = :_read_existing_quickie_service
        @_touch_quickie_service = :_read_existing_quickie_service
        @__existing_quickie_service = svc ; nil
      end

      def __dereference_quickie_service_
        send @_read_quickie_service
      end

      def _read_existing_quickie_service
        @__existing_quickie_service
      end

      def __determine_if_quickie_has_reign

        # only once ever per "runtime" (and just before we "start" the
        # service) check to see if r.s is loaded. if it is, do *nothing*
        # later on down the line..

        if @toplevel_module.const_defined? :RSpec
          @__quickie_has_reign = false
        else
          @__quickie_has_reign = true
          @kernel_module.send :define_method, :should, DEFINITION_FOR_THE_METHOD_CALLED_SHOULD___
        end
        @_quickie_has_reign = :__quickie_has_reign
        send @_quickie_has_reign
      end

      def __quickie_has_reign
        @__quickie_has_reign
      end
    end

    # ==

    DEFINITION_FOR_THE_METHOD_CALLED_SHOULD___ = -> predicate do
      predicate.matches? self  # allà r.s
    end

    DEFINITION_FOR_THE_METHOD_CALLED_WHINE__ = -> tail_sym, & msg do
      self._SOON
    end

    DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
      if x
        instance_variable_set ivar, x ; ACHIEVED_
      else
        x
      end
    end

    # ==

    class Service_via_InjectedClient__

      def initialize cli, kernel_mod
        @_client = cli
        @_kernel_module = kernel_mod
        @_receive_TCC = :__receive_first_TCC_in_basic_mode
        @_thing_mutex = nil
      end

      def __begin_irreversible_one_time_compound_mode_
        remove_instance_variable :@_thing_mutex
        @_long_running_statistics = StatisticsAggregator___.new @_client  # starts time
        @_receive_TCC = :__receive_TCC_in_compound_mode ; nil
      end

      def _receive_describe p, s_a
        tcc = ::Class.new Context__  # test context class
        Initialize_context_class__[ tcc, p, s_a ]
        send @_receive_TCC, tcc
      end

      def __receive_first_TCC_in_basic_mode tcc
        remove_instance_variable :@_thing_mutex
        @_receive_TCC = :__receive_subsequent_TCC_in_basic_mode
        _receive_TCC_in_basic_mode tcc
      end

      def __receive_subsequent_TCC_in_basic_mode tcc
        self._COVER_ME
        me = self  # #open [#008]
        @_client.listener.call :info, :expression, :multiple_describes do |y|
          y << me.__say_multiple_describes
        end
        @_receive_TCC = :_receive_TCC_in_basic_mode
        send @_receive_TCC, tcc
      end

      def __say_multiple_describes
        self._NOT_YET_COVERED
        "quickie note - if you want to have multiple root-level #{
            }`describe`s aggregated into one test run, you should try #{
            }the undocumented, experimental recursive test runner. running #{
            }them individually."
      end

      def __receive_TCC_in_compound_mode tcc

        RunTests_via_TestContextClass_and_Client__.define do |o|
          o.client = @_client
          o.statistics_aggregator = @_long_running_statistics
          o.test_context_class = tcc
        end.execute
        NIL
      end

      def _receive_TCC_in_basic_mode tcc

        stats = StatisticsAggregator___.new @_client  # starts time

        RunTests_via_TestContextClass_and_Client__.define do |o|
          o.client = @_client
          o.statistics_aggregator = stats
          o.test_context_class = tcc
        end.execute

        stats.close
        @_client.receive_test_run_conclusion stats

        NIL
      end

      def __end_irreversible_one_time_compound_mode_
        @_receive_TCC = :_COMPOUND_SESSION_CLOSED
        remove_instance_variable :@_long_running_statistics
      end
    end

    # === INVOCATION ===

    class RunTests_via_TestContextClass_and_Client__ < Common_::SimpleModel

      attr_writer(
        :client,
        :statistics_aggregator,
        :test_context_class,
      )

      def execute
        client = @client
        eg_st = Exampler_via___[ @test_context_class, client ]
        stats = @statistics_aggregator
        begin
          eg = eg_st.call
          eg || break
          if false && do_skip
            client.express_skip
            redo
          end
          block = eg.block
          if ! block
            stats.tick_pending
            redo
          end
          # puts "#{ indent[] }<<#{ eg.description }>>"

          stats.tick_example
          ctx = eg.context.new stats
          if eg.has_before_each
            eg.run_before_each ctx
          end
          ctx.instance_exec( & block )
          redo
        end while above
        client.flush
        NIL
      end
    end

    # ==

    class Choices_via_AssignmentsProc_and_Client__

      # responsibility: parse arguments in a modality-agnostic way & represent

      class << self
        def call client, & p
          new( p, client ).execute
        end
        private :new
      end  # >>

      def initialize p, c
        @client = c ; @proc = p
      end

      def execute
        @_ok = true
        @writable_choices = Choices___.new
        _ok = remove_instance_variable( :@proc )[ self ]
        _ok && @_ok && __finish
      end

      def write_formal_primaries_into receiver
        PRIMARIES___.__elements_.each do |hi|
          self._NOT_YET_COVERED
          receiver.add_primary hi.name_symbol, & hi.proc
        end
        NIL
      end

      def __finish
        remove_instance_variable( :@writable_choices ).freeze
      end

      attr_reader(
        :writable_choices,
      )
    end

    # ==

    class StatisticsAggregator___

      # primary responsibility: maintain "statistics" (just simple counts)
      # of example-level events (namely pass, fail or pend) via receiving
      # notification of same.
      #
      # secondarily, at the same time dispatch each such event to the client
      # for expression.
      #
      # finally, keep track of time.

      def initialize client

        @_client = client
        @_eg_is_failed = nil
        @__time_one = ::Time.now

        @example_count = 0
        @example_failed_count = 0
        @example_pending_count = 0
      end

      # ~ write

      def _receive_fail msg_p

        # (it's possible for one example to fail several times)

        if ! @_eg_is_failed
          @_eg_is_failed = true
          @example_failed_count += 1  # before below (render e.g "(FAILED - 2)")
        end

        @_client.receive_failure msg_p, @example_failed_count

        UNABLE_
      end

      def __receive_pass msg_p
        @_client.receive_pass msg_p
        :_quickie_passed_
      end

      def tick_example
        @_eg_is_failed = nil
        @example_count += 1 ;  nil
      end

      def tick_pending
        @_eg_is_failed = nil
        @example_pending_count += 1
        @_client.receive_pending
        NIL
      end

      def close
        @elapsed_time = ::Time.now - remove_instance_variable( :@__time_one )
        remove_instance_variable :@_client
        remove_instance_variable :@_eg_is_failed
        freeze
        NIL
      end

      # ~ read

      attr_reader(
        :elapsed_time,
        :example_count,
        :example_failed_count,
        :example_pending_count,
      )
    end

    # ==

    # === CLIENT ADAPTATION: CLI ===

    DEFINITION_FOR_THE_METHOD_CALLED_STYLIZE___ = -> sym, s do
      Stylize__[ sym, s ]
    end

    class CLI_InjectedClient_via_StandardFive___ < Common_::Monadic

      def initialize five
        @show_help = false
        @_ARGV, _, @_stdout, @_stderr, @_program_name_string_array = five
        @_do_invite = false
      end

      def execute
        if @_ARGV.length.zero?
          __client_without_choices
        else
          __when_arguments
        end
      end

      def __when_arguments
        __convert_leading_line_numbers_shorthand_switches
        if ! __resolve_choices
          __unable
        elsif @_ARGV.length.nonzero?
          __when_extra_arguments
        elsif @show_help
          __express_help
        else
          _client_via_choices @_choices
        end
      end

      def __convert_leading_line_numbers_shorthand_switches
        Convert_leading_line_number_shorthand_switches___[ @_ARGV ] ; nil
      end

      def __resolve_choices  # assme ARGV

        _ = Choices_via_AssignmentsProc_and_Client__.call self do |cx|
          @writable_choices = cx.writable_choices
          @formal_choices_reader = cx
          __init_option_parser
          begin
            @_option_parser.parse! @_ARGV
            ACHIEVED_
          rescue ::OptionParser::ParseError => e
            __when_optparse_parse_error e
          end
        end
        _store :@_choices, _
      end

      def __express_help
        io = @_stderr
        io.puts "usage: ruby TEST_FILE [options]"
        io.puts
        io.puts "options:"
        @_option_parser.summarize( & io.method( :puts ) )
        NIL
      end

      def __when_optparse_parse_error e
        @_stderr.puts e.message
        _invite
      end

      def __when_extra_arguments
        argv = @_ARGV
        @_stderr.puts "unexpected argument#{ 's' if 1 != argv.length }: #{
          }#{ argv[0].inspect }#{ ' [..]' if argv.length > 1 }"
        _invite
      end

      def __unable
        @_do_invite && _invite
        UNABLE_
      end

      def _invite
        @_stderr.puts "try 'ruby #{ __invocation_string } -h' for help"
        UNABLE_
      end

      def __invocation_string
        @_program_name_string_array * SPACE_
      end

      def __client_without_choices
        _client_via_chioces NOTHING_
      end

      def _client_via_chioces cx
        CLI_InjectedClient___.new cx, @_stdout, @_stderr
      end

      def __init_option_parser

        @__first_time_letter = ::Hash.new { |h, k| h[k] = false ; true }

        require 'optparse'  # or Lib_::OptionParser
        ::OptionParser.new do |o|
          @_option_parser = o
          _cxr = remove_instance_variable :@formal_choices_reader
          _cxr.write_formal_primaries_into self
          __add_bespoke_primaries
        end
        NIL
      end

      def __add_bespoke_primaries
        @_option_parser.on '-h', '--help' do
          @show_help = true
          NIL
        end
        NIL
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    class CLI_InjectedClient___

      # responsibility: express all node-level events (e.g when we cross
      # during traversal an example, a context) via notifications of them.

      # this is rewrite of perhaps the most dense (yet self-contained)
      # "function soup" we've ever seen.. this replacement is only a slight
      # improvement: it still has lots of fragile state signified by the
      # "EEK" ivars, which needs cleanup

      # #storypoint-465 has the legacy intro, still relevant

      def initialize cx, so, se

        if cx
          self._ETC
          # @choices = cx
          @_has_search_criteria = true
        else
          @_has_search_criteria = false
        end

        @_EEK_branch_cache = []  # each most recent branch indexed by its depth.
        @_EEK_branch_offset = 0  # index into the above
        @_EEK_eg_category = :pass  # the first example, even w/ no tests, is still 'pass'
        @_EEK_failure_count = nil
        @_EEK_flush = :_nothing
        @_EEK_depth = nil  # horrible

        @_stderr = se
        # @_stdout = so
        @_tab = '  '
      end

      def begin_branch_node d, ctx
        send @_EEK_flush
        if ctx.is_pending
          ::Kernel._K
        else
          __cache_branch d, ctx  # either this
          # _express_branch d, ctx  # or this
        end
        NIL
      end

      def __cache_branch d, ctx
        if d < @_EEK_branch_offset
          # anytime we put a fresh branch at a deeper depth, note that
          @_EEK_branch_offset = d
        end
        @_EEK_branch_cache[ d ] = ctx ; nil
      end

      def begin_leaf_node d, eg  # called when we *begin* an example
        send @_EEK_flush
        @_EEK_flush = :_flush_leaf
        @_EEK_depth = d
        @_EEK_eg = eg ; nil
      end

      # -- called by statistics only

      def receive_failure msg_p, failure_count

        @_EEK_eg_category = :fail
        @_EEK_failure_count = failure_count
        send @_EEK_flush

        _some_message = msg_p[] or Here_._DESGIN_ME__no_failure_message__
        _puts "#{ _say_indent @_EEK_depth }#{ SPACE_ }#{ SPACE_ }#{
          }#{ _stylize :red, _some_message }"

        NIL
      end

      def receive_pass msg_p

        # (maybe if verbose we would emit the message but generally this is
        # too noisy and/or there is not a message for every pass). #tombstone-A

        # we don't flush yet because subsequent tests in the example might
        # stil fail.

        @_EEK_eg_category = :pass
        NIL
      end

      def receive_pending

        @_EEK_eg_category = :pend
        send @_EEK_flush
        NIL
      end

      # --

      def flush
        _flush_leaf  # hi.
      end

      def _flush_leaf
        __flush_branches
        send EXPRESS_EXAMPLE___.fetch @_EEK_eg_category
        remove_instance_variable :@_EEK_eg
        @_EEK_flush = :_nothing
        @_EEK_eg_category = :pass  # examples with no tests still pass
        # don't ever clear @_EEK_branch_offset - we use it after flush..
        NIL
      end

      def __flush_branches
        ( @_EEK_branch_offset ... @_EEK_depth ).each do |d|
          __express_branch d, @_EEK_branch_cache.fetch( d )
        end
        @_EEK_branch_offset = @_EEK_depth ; nil
          # in the future, only render branches at this depth or >
          # unless we see a new branch that is <, then change it
      end

      def __express_branch d, ctx
        if ctx.is_pending  # experimental non-r.s feature
          ::Kernel._K
        else
          _puts "#{ _say_indent d }#{ ctx.description }"
        end
        NIL
      end

      EXPRESS_EXAMPLE___ = {
        fail: :__express_fail,
        pass: :__express_pass,
        pend: :__express_pend,
      }

      def __express_fail
        _puts "#{ _say_indent @_EEK_depth }#{
          }#{ _stylize :red, "#{ @_EEK_eg.description } (FAILED - #{ @_ordinal })" }"
        NIL
      end

      def __express_pend
        _puts "#{ _say_indent @_EEK_depth }#{
          }#{ _stylize :yellow, "#{ @_EEK_eg.description }" }"
        NIL
      end

      def __express_pass
        _puts "#{ _say_indent @_EEK_depth }#{
          }#{ _stylize :green, @_EEK_eg.description }"
        NIL
      end

      # --

      def receive_test_run_conclusion stats

        e_d = stats.example_count
        f_d = stats.example_failed_count
        p_d = stats.example_pending_count

        if e_d.zero?
          if @_has_search_criteria
            _puts "All examples were filtered out"
          else
            _puts "No examples found.#{ NEWLINE_ }#{ NEWLINE_ }"  # <- trying to look like r.s there
          end
        end

        _puts "#{ NEWLINE_ }Finished in #{ stats.elapsed_time } seconds"

        np = -> d, s do  # (or move to expag)
          "#{ d } #{ s }#{ 's' if 1 != d }"
        end

        if p_d.nonzero?
          _ = ", #{ p_d } pending"
        end

        _msg = "#{ np[ e_d, "example" ] }, #{ np[ f_d, "failure" ] }#{ _ }"
        _color = f_d.zero? ? p_d.zero? ? :green : :yello : :red

        _puts _stylize( _color, _msg )
        NIL
      end

      # --

      def _say_indent d
        @_tab * d
      end

      define_method :_stylize, DEFINITION_FOR_THE_METHOD_CALLED_STYLIZE___

      def _puts s
        @_stderr.puts s
      end

      def _nothing
        NOTHING_
      end
    end

    # ==

    # === MODELS ===

    class Context__  # (will re-open)

      # (both instance- & singleton method namespaces of this are userland!)

      class << self

        def describe desc, * rest, & p
          context desc, * rest, & p
        end

        def description
          @_description_string_array[ 0 ]  # if any
        end

        def context * desc_s_a, & p
          cls = ::Class.new self
          Initialize_context_class__[ cls, @_tagset_hash, p, desc_s_a ]
          @_elements.push [ :branch, cls ] ; nil
        end

        def it * desc_s_a, & p

          _d = caller_locations( 1, 1 ).first.lineno
          _h = Tagset_hash_via__[ desc_s_a, @_tagset_hash ]  # pops array
          _sea = Searchables___[ _d, _h ]
          _eg = Example___.new _sea, p, desc_s_a, self
          @_elements.push [ :leaf, _eg ]
          NIL
        end

        def __elements_array_read_only_
          @_elements
        end

        attr_reader(
          :is_pending,
        )
      end  # >>

      def initialize o
        @__quickie_mutable_statistics__ = o  # REMINDER: ivar must be used in this file only!
      end

      def quickie_fail_with_message_by & msg_p

        # (experimental hack to allow custom matchers in both q & r.s)

        @__quickie_mutable_statistics__._receive_fail msg_p
        UNABLE_
      end

      Searchables___ = ::Struct.new :lineno, :tagset_hash

      # Home_::Let[ self ]
    end

    # ==

    Initialize_context_class__ = -> tcc, inherited_tagset_h=nil, p, desc_s_a do

      tcc.class_exec do

        @_tagset_hash = Tagset_hash_via__[ desc_s_a, inherited_tagset_h ]
        @_description_string_array = desc_s_a
        @_elements = []

        if p
          @is_pending = false
          class_exec( & p )
        else
          @is_pending = true
        end
      end
      NIL
    end

    # ==

    Tagset_hash_via__ = -> desc_s_a, inherited_tagset_h do

      if ::Hash === desc_s_a.last  # meh
        self._DO_ME
      end

      if inherited_tagset_h
        self._DO_ME
      end
    end

    # ==
if false
    class Tagset__

      def initialize * a
        @ts_h, @lineno = a
      end

      attr_reader :lineno

      def [] sym
        @ts_h && @ts_h[ sym ]
      end
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
end  # if false

    Exampler_via___ = -> ctx_class, client do

      branch = client.method :begin_branch_node
      leaf = client.method :begin_leaf_node
      stack = [] ; cur = ctx_class

    push = -> do
      els = cur.__elements_array_read_only_
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

if false

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
end  # if false

    Stylize__ = -> do  # #open :[#005]. #[#ze-023.2] the stylize diaspora
      h = ::Hash[ %i| red green yellow blue magenta cyan white |.
        each_with_index.map do |i, d| [ i, 31 + d ] end ]
      h[ :strong ] = 1 ; p = h.method :fetch
      -> i, s do
        "\e[#{ p[ i ] }m#{ s }\e[0m"
      end
    end.call

if false

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

    def ___build_example_stream_proc branch, leaf
      if @_example_stream_p_p
        @_example_stream_p_p[ branch, leaf ]
      else
        Build_example_stream_proc_[ @root_context_class, branch, leaf ]
      end
    end

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

    # -> (net: 0)

end  # if false

    class Example___

      # simple data structure for holding e.g `it` and its block

      def initialize searchables, block, desc, context
        @__description_string_array = desc
        @block = block
        @context = context
        @searchables = searchables
      end

      def description
        @__description_string_array.first
      end

      def has_before_each
        false  # only while not covered
      end

      attr_reader(
        :block,
        :context,
        :searchables,
      )
    end

    # === FEATURE: predicates (core) ==

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

      def initialize sa, ctx, * rest

        ivars = self.class.ivars
        rest.each_with_index do |x, d|
          instance_variable_set ivars.fetch( d ), x
        end

        @context = ctx
        @_statistics_aggregator = sa
      end

      def _pass_by & msg_p

        @_statistics_aggregator.__receive_pass msg_p
      end

      def _fail_by & msg_p

        @_statistics_aggregator._receive_fail msg_p
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

  # for each const in the predicates module (each of which must be a
  # predicate class) define the corresponding context instance method

  Methify_const___ = -> const do  # FooBar NCSASpy CrackNCSACode FOO  # #todo - use [cb] name
    const.to_s.gsub( /
     (    (?<= [a-z] )[A-Z] |
          (?<= . ) [A-Z] (?=[a-z]))
     /x ) { "_#{ $1 }" }.downcase.intern
  end

  class Context__  # re-open
    Predicates__.constants.each do |const|
      cls = Predicates__.const_get const, false
      meth = Methify_const___[ const ]
      define_method meth do |*expected|
        cls.new @__quickie_mutable_statistics__, self, *expected
      end
    end
  end

    # === FEATURE: should `be_<foo>()` method_missing hack ===

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

        _cls.new @__quickie_mutable_statistics__, self, * args
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

    # ===

    primaries =
    module PRIMARIES___
      class << self
        def add_primary k, & p
          self._BOOYEAH
        end
        attr_reader :__elements_
        def __TEMPORARY_TOUCH__ ; nil end
      end  # >>
      @__elements_ = []
      self
    end

    choices_members = []  # order does not matter

    # === FEATURE: line-numbers (STUB) ===

    Convert_leading_line_number_shorthand_switches___ = -> do

      rx = /\d/

      -> argv do
        if rx =~ argv.fetch( 0 )
          self._RESTORE_ME
        end
      end
    end.call

    # === FEATURE: before hooks ===

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

    if choices_members.length.zero?
      choices_members.push :_placeholder_
    else
      self._OK__you_can_get_rid_of_this_fluff_now__
    end

    primaries.__TEMPORARY_TOUCH__
    Choices___ = ::Struct.new( * choices_members )

    module Plugins  # ..
      Autoloader_[ self, :boxxy ]
    end

    Here_ = self
  end
end
# :#tombstone-A.1: the previous: ( service, main run loop, rendering
#   functions, "runtime" (now "statistics"), `do_not_invoke!` )
