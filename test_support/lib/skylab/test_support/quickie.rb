module Skylab::TestSupport

  module Quickie  # see [#004] the quickie narrative #intro

    class << self

      # (these are the things that can't/shouldn't be covered)

      def enable_kernel_describe
        runtime_.__enable_kernel_describe
      end

      def extended mod  # :+[#sl-111] deprecteded `extended` pattern
        self._DEPRECATED__extending_quickie_is_deprecated__use_the_new_method_with_the_much_longer_name
      end

      def enhance_test_support_module_with_the_method_called_describe mod
        runtime_.__enhance_test_support_module_with_the_method_called_describe mod
        NIL
      end

      def runtime_
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
        send( @_enable_kernel_describe ||= :__enable_kernel_describe_initially )
      end

      def __enable_kernel_describe_initially

        @_enable_kernel_describe = :__runtime_nothing  # no matter what, called 1x

        # [#004.A] discusses the details of how we implement this

        if send @_quickie_has_reign
          __enable_kernel_describe_for_quickie
        end
        NIL
      end

      def __enable_kernel_describe_for_quickie
          me = self
          @kernel_module.send :define_method, :describe do |*desc_s_a, &p|
            svc = me._touch_quickie_service
            if svc
              _hm = svc._receive_describe p, desc_s_a
              _hm  # #todo
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

      def call_the_quickie_runtime_ * x_a, & p  # recursive runner plugins
        receive_API_call_ p, x_a
      end

      def receive_API_call_ p, x_a
        client = Here_::API::InjectedClient_via_Listener_and_Arguments[ p, x_a ]
        svc = ( client and _build_quickie_service_via_injected_client client )
        _write_first_and_only_service svc
        client and client.RECEIVE_RUNTIME_ self
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
        @quickie_service_is_running__ = true
        @_touch_quickie_service = :_read_existing_quickie_service
        @__existing_quickie_service = svc ; nil
      end

      attr_reader :quickie_service_is_running__  # for now, for recursive runner

      def dereference_quickie_service_
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
          # @kernel_module.send :define_method, :should, DEFINITION_FOR_THE_METHOD_CALLED_SHOULD___
        end
        @_quickie_has_reign = :__quickie_has_reign
        send @_quickie_has_reign
      end

      def __quickie_has_reign
        @__quickie_has_reign
      end

      def __runtime_nothing
        NOTHING_  # hi.
      end
    end

    # ==

    DEFINITION_FOR_THE_METHOD_CALLED_WHINE__ = -> tail_sym, & msg do

      me = self
      current_primary_symbol_hello = self.current_primary_symbol

      listener.call :error, :expression, :parse_error, tail_sym do |y|

        if ! msg
          md = /\A.+_is_/.match tail_sym
          _ = if md
            "cannot be #{ md.post_match }"
          else
            tail_sym.id2name
          end
          _template = "{{ curr_prim }} #{ _.gsub UNDERSCORE_, SPACE_ }"
          msg = -> { _template }
        end

        use_y = ::Enumerator::Yielder.new do |unexpanded_line|
          _final_line = unexpanded_line.gsub MUSTACHE_RX___ do
            param_sym = $~[ :name ].intern
            case param_sym
            when :curr_prim
              prim current_primary_symbol_hello
            when :ick_mixed_value
              ick me.mixed_value
            else
              raise ::NameError, param_sym
            end
          end
          y << _final_line
        end

        if msg.arity.zero?
          _unexpanded_line = calculate( & msg )
          use_y << _unexpanded_line
        else
          calculate use_y, & msg
        end
        y
      end

      UNABLE_  # <- the result of (usu.) `_whine`
    end

    MUSTACHE_RX___ = /\{\{[ ]*(?<name>[a-z]+(?:_[a-z]+)*)[ ]*\}\}/

    # ==

    class Service_via_InjectedClient__

      def initialize cli, kernel_mod
        @_client = cli
        @_kernel_module = kernel_mod
        @_receive_TCC = :__receive_first_TCC_in_basic_mode
        @_thing_mutex = nil
      end

      def begin_irreversible_one_time_compound_mode_
        remove_instance_variable :@_thing_mutex
        @_long_running_statistics = _build_and_start_statistics
        @_receive_TCC = :__receive_first_TCC_in_compound_mode ; nil
      end

      def _receive_describe p, s_a  # #testpoint
        tcc = ::Class.new Context__  # test context class
        Initialize_context_class__[ tcc, p, s_a ]
        send @_receive_TCC, tcc
      end

      def __receive_first_TCC_in_basic_mode tcc

        @_client.at_beginning_of_test_run

        remove_instance_variable :@_thing_mutex
        @_receive_TCC = :__receive_subsequent_TCC_in_basic_mode
        _receive_TCC_in_basic_mode tcc
      end

      def __receive_subsequent_TCC_in_basic_mode tcc
        self._COVER_ME  #open [#007.D]
        @_client._puts __say_multiple_describes_NOT_COVERED
        @_receive_TCC = :_receive_TCC_in_basic_mode
        send @_receive_TCC, tcc
      end

      def __say_multiple_describes_NOT_COVERED
        "quickie note - if you want to have multiple root-level #{
            }`describe`s aggregated into one test run, you should try #{
            }the undocumented, experimental recursive test runner. running #{
            }them individually."
      end

      def __receive_first_TCC_in_compound_mode tcc

        @_test_runner_prototype = RunTests_via_TestContextClass_and_Client__.define do |o|
          o.client = @_client
          o.statistics_aggregator = @_long_running_statistics
        end

        @_client.at_beginning_of_test_run

        @_receive_TCC = :__receive_TCC_in_compound_mode
        send @_receive_TCC, tcc
        NIL
      end

      def __receive_TCC_in_compound_mode tcc

        _runner = @_test_runner_prototype.dup_by do |o|
          o.test_context_class = tcc
        end
        _runner.execute
        NIL
      end

      def _receive_TCC_in_basic_mode tcc

        stats = _build_and_start_statistics

        RunTests_via_TestContextClass_and_Client__.define do |o|
          o.client = @_client
          o.statistics_aggregator = stats
          o.test_context_class = tcc
        end.execute

        stats.close
        @_client.receive_test_run_conclusion stats

        NIL
      end

      def _build_and_start_statistics
        cx = @_client._choices_
        if cx
          choice = cx.statistics_class
        end
        if choice
          cx.statistics_class = NOTHING_  # THE WORST
          choice.value.new @_client  # should start time
        else
          StatisticsAggregator___.new @_client  # starts time
        end
      end

      def end_irreversible_one_time_compound_mode_
        @_receive_TCC = :_COMPOUND_SESSION_CLOSED
        stats = remove_instance_variable :@_long_running_statistics
        stats.close  # or move out outward for whatever reason
        stats
      end
    end

    # === INVOCATION ===

    class RunTests_via_TestContextClass_and_Client__ < Common_::SimpleModel

      # typically one such performer is build (or duped) for every test file

      def initialize
        @documentation_only = false
        @_reduction_proc = MONADIC_TRUTH_
        super
      end

      def dup_by
        otr = dup
        yield otr
        otr
      end

      attr_writer(
        :statistics_aggregator,
        :test_context_class,
      )

      def client= cli
        cx = cli._choices_
        if cx
          cx.members.each do |mem|
            x = cx[ mem ]
            x || next
            send RECEIVE_CHOICE___.fetch( mem ), x
          end
        end
        @client = cli
      end

      RECEIVE_CHOICE___ = {  # sanity for when new choices are added
        do_documentation_only: :__receive_doc_only,
        reducers: :__receive_reducers,
      }

      def __receive_doc_only _
        @documentation_only = true
      end

      def __receive_reducers red
          @_reduction_proc = red.to_proc
        NIL
      end

      def execute

        client = @client
        eg_st = Exampler_via___[ @test_context_class, client ]
        reduction_proc = @_reduction_proc
        stats = @statistics_aggregator

        begin

          eg = eg_st.call
          eg || break

          _stay = reduction_proc[ eg ]
          if ! _stay
            client.receive_skip
            # (before this cluster there was some commented out expression)
            redo
          end

          block = eg.block
          if ! block
            stats.tick_pending
            redo
          end

          # puts "#{ indent[] }<<#{ eg.description }>>"

          if @documentation_only
            stats.tick_documentation_only
            redo
          end

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

    class Choices_via_AssignmentsProc_and_Client_

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
        ok = __call_proc
        ok &&= __close_choices
        ok and remove_instance_variable :@__frozen_choices
      end

      def __close_choices
        _cx = remove_instance_variable :@writable_choices
        _store :@__frozen_choices, _cx.finish
      end

      def __call_proc
        @writable_choices = Choices___.new
        _ok = remove_instance_variable( :@proc )[ self ]
        _ok  # #todo
      end

      def write_formal_primaries_into receiver
        PRIMARIES___.__elements_.each do |(sym, p)| # :#here
          receiver.add_primary sym, & p
        end
        NIL
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

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

      def tempurature_between_zero_and_ten_inclusive
        @example_failed_count.zero? ? @example_pending_count.zero? ? 0 : 5 : 10
      end

      def main_count_is_zero
        @example_count.zero?
      end

      def to_qualified_datapoint_stream
        a = []
        a.push QualifiedDatapoint_.new( @example_count, "example" )
        a.push QualifiedDatapoint_.new( @example_failed_count,  "failure" )
        a.push QualifiedDatapoint_.new( @example_pending_count, "pending", false, false )
        Stream_[ a ]
      end

      attr_reader(
        :elapsed_time,
        # maybe only #testpoint(s):
        :example_count,
        :example_failed_count,
      )
    end

    class QualifiedDatapoint_

      # a simple name-value pair plus rough hax for EN linguistic inflection

      def initialize d, s, plur=true, show_zero=true
        @__infer_pluralization = plur
        @_lemma = s
        @_number = d
        @__zero_is_still_significant = show_zero
      end

      def is_known_known
        @_number.nonzero? || @__zero_is_still_significant
      end

      def to_string sym
        :EN == sym || self._I18N
        _lexeme = if 1 == @_number || ! @__infer_pluralization
          @_lemma
        elsif @_lemma.include? SPACE_
          s_a = @_lemma.split SPACE_
          s_a.first << 's'
          s_a * SPACE_
        else
          "#{ @_lemma }s"
        end
        "#{ @_number } #{ _lexeme }"
      end
    end

    # ==

    # === CLIENT ADAPTATION: CLI ===

    DEFINITION_FOR_THE_METHOD_CALLED_STYLIZE___ = -> sym, s do
      Stylize__[ sym, s ]
    end

    class CLI_InjectedClient_via_StandardFive___ < Common_::Monadic

      def initialize five

        @_ARGV, _, sout, serr, @_program_name_string_array = five

        @_CLI_expression_resources = CLI_ExpressionResources_.define do |o|
          o.stdout = sout
          o.stderr = serr
          o.notify_that_should_invite_by = -> do
            @_do_invite = true
            @_ok = false
          end
        end

        @_do_invite = false
        @_ok = true
        @_stderr = serr

        @show_help = false
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

        _ = Choices_via_AssignmentsProc_and_Client_.call self do |cx|
          @_writable_choices = cx.writable_choices
          @_formal_choices_reader = cx
          __init_option_parser
          begin
            @_option_parser.parse! @_ARGV
            @_ok
          rescue ::OptionParser::ParseError => e
            __when_optparse_parse_error e
          end
        end

        @_ok and _store :@_choices, _
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
        _client_via_choices NOTHING_
      end

      def _client_via_choices cx
        CLI_InjectedClient_.define do |o|
          o.choices = cx
          o.CLI_expression_resources = @_CLI_expression_resources
        end
      end

      def __init_option_parser

        @__first_time_letter = ::Hash.new { |h, k| h[k] = false ; true }

        require 'optparse'  # or Lib_::OptionParser
        ::OptionParser.new do |o|
          @_option_parser = o
          _cxr = remove_instance_variable :@_formal_choices_reader
          _cxr.write_formal_primaries_into self
          __add_bespoke_primaries
        end
        NIL
      end

      def __add_bespoke_primaries
        @_option_parser.on '-h', '--help', 'this screen' do
          @show_help = true
          NIL
        end
        NIL
      end

      def add_primary k

        a = []

        prim = CLI_Primary_for_OptionParser___.define do |o|
          o.name_symbol = k
          yield o
        end

        slug = k.id2name.gsub UNDERSCORE_, DASH_

        letter = slug[0]

        if @__first_time_letter[ letter ]
          a.push "-#{ letter }"
        end

        if ! prim.is_flag
          _moniker_part = " #{ prim.__release_value_moniker_ }"
        end

        a.push "--#{ slug }#{ _moniker_part }"
        a.push prim.__release_description_line_

        write = -> x do
          write = CLI_PrimaryWriter___.call_by do |o|
            o.listener = @_CLI_expression_resources.listener
            o.primary = prim
            o.writable_client = @_writable_choices
          end
          write[ x ]
        end

        @_option_parser.on( * a ) do |x|
          write[ x ]
        end
        NIL
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    # ==

    Primary_ = ::Class.new Common_::SimpleModel

    class CLI_Primary_for_OptionParser___ < Primary_

      def initialize
        yield self
        # don't freeze
      end

      def didactics_by
        yield self
      end

      attr_writer(
        :description_line,
        :value_moniker,
      )

      def __release_description_line_
        remove_instance_variable :@description_line
      end

      def __release_value_moniker_
        remove_instance_variable :@value_moniker
      end
    end

    class CLI_InjectedClient_ < Common_::SimpleModel

      # responsibility: express all node-level events (e.g when we cross
      # during traversal an example, a context) via notifications of them.

      # this is rewrite of perhaps the most dense (yet self-contained)
      # "function soup" we've ever seen.. this replacement is only a slight
      # improvement: it still has lots of fragile state signified by the
      # "EEK" ivars, which needs cleanup

      # #storypoint-465 has the legacy intro, still relevant

      def choices= cx  # (historical placement)
        if cx
          @_choices_ = cx
          if cx.reducers
            has_reducers = true
          end
        end
        @_has_reducers = has_reducers
        cx
      end

      def initialize
        @load_tests_by = nil
        yield self
        @_EEK_branch_cache = []  # each most recent branch indexed by its depth.
        @_EEK_branch_offset = 0  # index into the above
        @_EEK_eg_category = :pass  # the first example, even w/ no tests, is still 'pass'
        @_EEK_failure_count = nil
        @_EEK_flush = :_CLI_client_nothing
        @_EEK_depth = nil  # horrible
        @_tab = '  '
      end

      def define
        # experimental for recursive runner
        yield self
        self
      end

      # --

      def CLI_expression_resources= rsx
        @__test_line_downstream = rsx.stdout
        rsx
      end

      def _listener_= x
        @LISTENER = x
      end

      def _choices_= cx
        self.choices = cx
      end

      attr_writer :load_tests_by

      # ~

      def RECEIVE_RUNTIME_ rt

        # the recursive runner CLI is invoked. to run tests, it calls the
        # onefile API and in that call it injects an injected client. that
        # client is the subject. partial copypasta with the counterpart.

        svc = rt.dereference_quickie_service_

        svc.begin_irreversible_one_time_compound_mode_

        @load_tests_by[ rt ]  # result is specified as insignificant

        stats = svc.end_irreversible_one_time_compound_mode_
        receive_test_run_conclusion stats
        stats
      end

      # --

      def at_beginning_of_test_run
        @_has_reducers && __express_reducers
        NIL
      end

      def __express_reducers

        # this doesn't modularize along the same axis as its components:
        # there is any one line for "includes" and any one for "excludes";
        # line ranges are always expressed as the former and tags could be
        # either. visitor pattern would be overkill.
        # this is near #open [#009.B] how it differs subtly from r.s

        include = nil ; exclude = nil

        via_bc = {
          _tags_: -> bg do
            bg.reducers.each do |red|
              h = if red.positive_not_negative
                include ||= {}
              else
                exclude ||= {}
              end
              ( h[ :_tags_ ] ||= [] ).push(
                ":#{ red.tag_symbol }=>#{ red.mixed_tag_value }" )
            end
          end,
          _line_ranges_: -> bg do
            _h = ( include ||= {} )
            a = ( _h[ :_line_ranges_ ] ||= [] )
            bg.reducers.each do |red|
              a.push red.say_line_range  # eg. "156"
            end
          end,
        }

        @_choices_.reducers.AND.each_value do |bg|
          via_bc.fetch( bg.business_category_symbol )[ bg ]
        end

        say = {
          _line_ranges_: -> s_a do
            ":line_numbers=>[#{ s_a * ',' }]"
          end,
          _tags_: -> s_a do
            s_a.join ', '
          end,
        }

        a = []
        say_line_body = -> h do
          buffer = "{"
          yes = false
          h.each_pair do |k, v|
            if yes
              buffer << ', '
            else
              yes = true
            end
            buffer << say.fetch( k )[ v ]
          end
          buffer << "}"
        end
        if include
          a.push "include #{ say_line_body[ include ] }"
        end
        if exclude
          a.push "exclude #{ say_line_body[ exclude ] }"
        end
        if 1 == a.length
          _puts "Run options: #{ a.first }"
        else
          _puts "Run options:"
          a.each { |s| _puts "#{ SPACE_ }#{ SPACE_ }#{ s }" }
        end

        _puts nil  # blank line
        NIL
      end

      def begin_branch_node d, ctx
        send @_EEK_flush
        if ctx.is_pending
          # ::Kernel._COVER_ME__pending_not_covered_for_quickie__  # #todo
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

      def receive_skip
        _clear_example  # hi.
        NIL
      end

      # --

      def flush
        send @_EEK_flush
        NIL
      end

      def _flush_leaf
        __flush_branches
        send EXPRESS_EXAMPLE___.fetch @_EEK_eg_category
        _clear_example
        NIL
      end

      def _clear_example
        remove_instance_variable :@_EEK_eg
        @_EEK_flush = :_CLI_client_nothing
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
          }#{ _stylize :red, "#{ @_EEK_eg.description } (FAILED - #{ @_EEK_failure_count })" }"
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

        if stats.main_count_is_zero
          if @_has_reducers
            _puts "All examples were filtered out"
          else
            _puts "No examples found.#{ NEWLINE_ }#{ NEWLINE_ }"  # <- trying to look like r.s there
          end
        end

        _puts "#{ NEWLINE_ }Finished in #{ stats.elapsed_time } seconds"

        _msg = stats.to_qualified_datapoint_stream.reduce_by do |o|
          o.is_known_known
        end.join_into_with_by "", ", " do |o|
          o.to_string :EN
        end

        _color = case stats.tempurature_between_zero_and_ten_inclusive
        when 0...3 ; :green   # cool
        when 3...7 ; :yellow  # warm
        when 7..10 ; :red     # hot
        end

        _puts _stylize( _color, _msg )
        NIL
      end

      # --

      def _say_indent d
        @_tab * d
      end

      define_method :_stylize, DEFINITION_FOR_THE_METHOD_CALLED_STYLIZE___

      def _puts s
        @__test_line_downstream.puts s
      end

      def _CLI_client_nothing
        NOTHING_
      end

      attr_reader :_choices_
    end

    # ==

    Integer_via_ParsePrimary_ = -> o do  # assume string
      # -
        _s = o.mixed_value
        md = INTEGER_RX___.match _s
        if md
          md[0].to_i
        else
          _ = o.whine :must_be_digit
          _  # #todo
        end
      # -
    end

    INTEGER_RX___ = /\A-?\d+\z/

    # ==

    class CLI_ExpressionResources_ < Common_::SimpleModel

      def initialize
        yield self
      end

      attr_writer :notify_that_should_invite_by, :stderr, :stdout

      def listener
        @___listener ||= method :__receive_emission
      end

      def __receive_emission * channel, & msg
        expression_agent.calculate info_yielder, & msg
        if :parse_error == channel.fetch( 2 )
          @notify_that_should_invite_by.call
        end
        NIL
      end

      def expression_agent
        CLI_InterfaceExpressionAgent.instance
      end

      def info_yielder
        @___info_yielder ||= __build_info_yielder
      end

      def __build_info_yielder
        ::Enumerator::Yielder.new do |line|
          @stderr.puts line
        end
      end

      attr_reader :stderr, :stdout
    end

    # ==

    class CLI_InterfaceExpressionAgent

      # (this has become an an ersatz of what is in [ze] nodeps, which is great)

      class << self
        def instance
          @___instance ||= new
        end
        private :new
      end  # >>

      alias_method :calculate, :instance_exec

      def simple_inflection & p
        o = dup
        o.extend Zerk_lib_[].lib_.human::NLP::EN::SimpleInflectionSession::Methods
        o.calculate( & p )
      end

      def ick_prim sym
        %("#{ prim sym }")
      end

      def ick x
        x.inspect
      end

      def prim sym
        "--#{ sym.id2name.gsub UNDERSCORE_, DASH_ }"
      end
    end

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
          _eg = Example__.new _sea, p, desc_s_a, self
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

      def expect actual_x
        ActualValueWrapped___.new actual_x
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

    class ActualValueWrapped___

      def initialize x
        @__actual_value = x ; freeze
      end

      def to pred
        pred.matches? @__actual_value
      end

      # def not_to  # ..
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

    Stylize__ = -> do  # #[#ze-023.2] the stylize diaspora
      h = ::Hash[ %i| red green yellow blue magenta cyan white |.
        each_with_index.map do |i, d| [ i, 31 + d ] end ]
      h[ :strong ] = 1 ; p = h.method :fetch
      -> i, s do
        "\e[#{ p[ i ] }m#{ s }\e[0m"
      end
    end.call

    class Example__

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
    const.id2name.gsub( /
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

        md = BE_RX___.match meth.id2name
        if md
          ___be_the_predicate_you_wish_to_see md, args, p
        else
          super meth, *args, &p
        end
      end

      BE_RX___ = /\Abe_(?<be_what>[a-z][_a-z0-9]*)\z/

      def ___be_the_predicate_you_wish_to_see md, args, p

        const = Constantize_method_name___[ md.string ]

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

      Constantize_method_name___ = -> s do
        # foo_bar !ncsa_spy !crack_ncsa_code foo
        s.gsub( /(?:^|_)([a-z])/ ) { $1.upcase }.intern
      end

      insp = nil

      No_Method___ = -> context, predicate, actual do
        fail "expected #{ insp[ actual ] } to have a #{
          }`#{ predicate.expected_method_name }` method"
        NIL_
      end

      insp = -> x do # yeah..
        str = x.inspect
        str.length > 80 ? x.class.name : str  # WHATEVER
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

    # === FEATURES PRE-SUPPPORT ===

    primaries =
    module PRIMARIES___
      class << self
        def add_primary k, & p
          @__elements_.push [ k, p ]  # :#here
        end
        attr_reader :__elements_
      end  # >>
      @__elements_ = []
      self
    end

    choices_members = []  # order does not matter

    choices_members.push(
      :do_documentation_only,  # for recursive runner
      :statistics_class,  # for recursive runner
    )

    # === FEATURE: line-number-ranges ===

    Convert_leading_line_number_shorthand_switches___ = -> do

      # convert head-anchored tokens like "-123" to "--line" "123".
      # we require these to be head-anchored as an easy way to avoid parsing
      # arguments for other options; contrast to [#br-074].
      # the platform o.p is not sympathetic to causes like this at all.

      rx = /\A-(?<lineno>\d+)(?:[-:](?<to_lineno>\d+))?\z/

      -> argv do
        d = 0
        begin

          md = rx.match argv.fetch d
          md || break

          line_s = md[ :lineno ]
          to_s = md[ :to_lineno ]

          insert_a = if to_s
            [ '--from', line_s, '--to', to_s ]
          else
            [ '--line', line_s ]
          end
          argv[ d, 1 ] = insert_a
          d += insert_a.length
        end until argv.length == d
        NIL
      end
    end.call

    # ==

    -> do

      same = 'NUMBER'

      primaries.add_primary :line do |fo|

        fo.didactics_by do |o|
          o.description_line = "run the example whose line number equals this"
          o.value_moniker = same
        end

        fo.write_primary_by do |o|
          ParseLine_via_ParsePrimary__[ o ]
        end
      end

      primaries.add_primary :from do |fo|

        fo.didactics_by do |o|
          o.description_line = "run the examples whose line number is >= this"
          o.value_moniker = same
        end

        fo.write_primary_by do |o|
          ParseLine_via_ParsePrimary__[ o ]
        end
      end

      primaries.add_primary :to do |fo|

        fo.didactics_by do |o|
          o.description_line = "run the examples whose line number is <= this"
          o.value_moniker = same
        end

        fo.write_primary_by do |o|
          ParseLine_via_ParsePrimary__[ o ]
        end
      end
    end.call

    # ==

    class ParseLine_via_ParsePrimary__ < Common_::Monadic

      def initialize o
        @parse_primary = o
      end

      def execute
        ok = true
        ok &&= __parse_integer
        ok && __touch_collection
        ok &&= __add_integer_to_collection
        ok
      end

      def __add_integer_to_collection

        _col = remove_instance_variable :@__reducers

        group = _col.touch_OR_group :_line_ranges_ do  # :#here-2
          IndicatedLineRanges___.new( & @parse_primary.listener )
        end

        _ranges = group.passenger

        type_sym = @parse_primary.primary.name_symbol

        _m = METHOD_VIA_PRIMARY___.fetch type_sym

        _ok = _ranges.send _m, remove_instance_variable( :@__integer )

        _ok  # #todo
      end

      METHOD_VIA_PRIMARY___ = {
        from: :receive_from, line: :receive_line, to: :receive_to,
      }

      def __touch_collection

        @__reducers = (
        @parse_primary.writable_client[ :reducers ] ||= MutableReducers__.new
        )
        NIL
      end

      def __parse_integer
        _store :@__integer, NonzeroPositiveInteger_via_ParsePrimary___[ @parse_primary ]
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    # ==

    class IndicatedLineRanges___

      # validate that line, range parameters don't overlap, etc

      def initialize & p
        @_has_dangling_from = false
        @_receive_range = :__receive_first_range
        @listener = p
      end

      def finish_for col
        _ok = __finish_any_dangling_from
        _ok and __do_finish col
      end

      def __do_finish bg
        bg.AND_not_OR && self._SANITY  # #here-2
        remove_instance_variable :@_receive_range
        _a = remove_instance_variable :@_sorted_range_array
        freeze
        _a.each do |range|
          bg.add_reducer range
        end
        ACHIEVED_
      end

      def __finish_any_dangling_from
        if @_has_dangling_from
          _from_d = remove_instance_variable :@_dangling_from
          _receive_range UnboundRange___.new _from_d
        else
          ACHIEVED_
        end
      end

      def receive_line d
        if @_has_dangling_from
          _whine_about_sequence [ "unclosed", :from ], :line
        else
          _receive_range IndicatedLine___.new d
        end
      end

      def receive_from d
        if @_has_dangling_from
          _whine_about_sequence [ "unclosed", :from ], :from
        else
          @_has_dangling_from = true
          @_dangling_from = d
          ACHIEVED_
        end
      end

      def receive_to d
        if @_has_dangling_from
          _receive_counterpart_to d
        else
          # (all `to` without a dangling `from` expands to `from line 1`)
          @_has_dangling_from = true
          @_dangling_from = 1
          _receive_counterpart_to d
        end
      end

      def _receive_counterpart_to d
        @_has_dangling_from = false
        from_d = remove_instance_variable :@_dangling_from
        if from_d < d
          _receive_range IndicatedRange___.new( from_d, d )
        else
          _whine :upsidedown_range do |y|
            y << "#{ prim :to } must be greater than #{ prim :from }"
            y << "(had from: #{ from_d } and to: #{ d })"
          end
        end
      end

      def _whine_about_sequence left_x, right_x
        _left_a = ::Array.try_convert( left_x ) || [ left_x ]
        _right_a = ::Array.try_convert( right_x ) || [ right_x ]
        _whine :bad_sequence do |y|
          p = -> a do
            a.map do |x|
              x.respond_to?( :id2name ) ? prim( x ) : x
            end * SPACE_
          end
          y << "#{ p[ _right_a ] } cannot follow #{ p[ _left_a ] }"
        end
      end

      def _receive_range o
        send @_receive_range, o
      end

      def __receive_first_range o
        @_receive_range = :__receive_subsequent_range
        @_sorted_range_array = [ o ] ; ACHIEVED_
      end

      def __receive_subsequent_range new

        a = @_sorted_range_array
        st = Common_::Stream.via_times a.length

        if new.is_bound
          new_end = new.end
          new_is_bound = true
        end

        begin  # find first current that is beyond or touching
          d = st.gets
          d || break
          current = a.fetch d

          if new_is_bound
            diff = current.begin - new_end
            rel = 1 <=> diff
          else
            rel = 1
          end

          case rel
          when -1
            found_cleanly_ahead = true
            break

          when 0
            _whine_about_kissing d, new
            failed = true ; break

          when 1  # current begin is before new end
            diff_ = new.begin - current.end
            rel_ = 1 <=> diff_
            case rel_
            when -1  # other ends cleanly before new one begins
              redo
            when 1
              _whine_about_overlap d, new
              failed = true ; break
            when 0
              _whine_about_kissing d, new
              failed = true ; break

            else ; never
            end
            never
          else ; never
          end
        end while above

        if failed
          UNABLE_
        elsif found_cleanly_ahead
          __maybe_insert_before d, new
        else
          sanity_last = a.fetch( -1 )
          1 < ( new.begin - sanity_last.end ) || fail
          a.push new
          ACHIEVED_
        end
      end

      def __maybe_insert_before d, new

        # the begin of the range at index d is "far" ahead of the new range.

        if d.zero?
          @_sorted_range_array[ 0, 0 ] = [ new ]
        else

          # since we are not inserting at the very beginning of the list,
          # sanity check to be sure that we clear *cleanly* the left
          # neighbor. (this should have been confirmed by caller. covered)

          _left_neighbor = @_sorted_range_array.fetch( d - 1 )
          new.begin > ( _left_neighbor.end + 1 ) || self._SANITY
          @_sorted_range_array[ d, 0 ] = [ new ]
        end
        ACHIEVED_
      end

      def _whine_about_kissing d, new
        _this_whine "kisses", d, new
      end

      def _whine_about_overlap d, new
        _this_whine "overlaps with", d, new
      end

      def _this_whine verb, d, new
        other = @_sorted_range_array.fetch d
        _whine :ranges_touch do |y|
          y << "#{ new.describe_under self } #{ verb } existing #{
            }#{ other.describe_under self }. combine these ranges."
        end
      end

      def _whine tail_sym, & msg
        @listener.call :error, :expression, :parse_error, tail_sym do |y|
          calculate y, & msg
        end
        UNABLE_
      end
    end

    LineRange__ = ::Class.new

    class IndicatedLine___ < LineRange__

      def initialize d
        @_digit = d
      end

      def describe_under expag
        d = @_digit
        expag.calculate { "#{ prim :line } #{ d }" }
      end

      def say_line_range
        "#{ @_digit }"
      end

      def to_proc
        -> eg do
          @_digit == eg.searchables.lineno
        end
      end

      attr_reader :_digit
      alias_method :begin, :_digit
      alias_method :end, :_digit

      def is_bound
        true
      end
    end

    class UnboundRange___ < LineRange__

      def initialize d
        @begin = d
      end

      def describe_under expag
        me = self
        expag.calculate do
          "range #{ prim :from } #{ me.begin } (unbound)"
        end
      end

      def say_line_range
        "#{ @begin }-#{ Infinity_glyph___[] }"  # EEEEEEEEEK
      end

      def to_proc
        -> eg do
          @begin <= eg.searchables.lineno
        end
      end

      attr_reader :begin

      def is_bound
        false
      end
    end

    class IndicatedRange___ < LineRange__

      def initialize d, d_
        @begin = d ; @end = d_
      end

      def describe_under expag
        me = self
        expag.calculate do
          "range #{ prim :from } #{ me.begin } #{ prim :to } #{ me.end }"
        end
      end

      def say_line_range
        "#{ @begin }-#{ @end }"
      end

      def to_proc
        -> eg do
          d = eg.searchables.lineno
          @begin <= d && @end >= d
        end
      end

      attr_reader :begin, :end

      def is_bound
        true
      end
    end

    class LineRange__
      def finish
        ACHIEVED_
      end
    end

    # === FEATURE: tags ===

    Tagset_hash_via__ = -> desc_s_a, inherited_tagset_h do

      if ::Hash === desc_s_a.last  # meh
        tagset_h = desc_s_a.pop  # meh
      end

      if inherited_tagset_h
        if tagset_h
          inherited_tagset_h.merge tagset_h
        else
          inherited_tagset_h
        end
      else
        tagset_h
      end
    end

    primaries.add_primary :tag do |fo|

      fo.didactics_by do |di|
        di.description_line = "(tries to be like the option in rspec)"
        di.value_moniker = 'TAG[:VALUE]'
      end

      fo.be_plural  # <- has no effect because of custom writer

      fo.write_primary_by do |o|
        ParseTag_via_ParsePrimary___[ o ]
      end
    end

    class ParseTag_via_ParsePrimary___ < Common_::Monadic

      def initialize o
        @listener = o.listener
        @mixed_value = o.mixed_value
        @primary = o.primary
        @writable_client = o.writable_client
      end

      def execute
        md = TAG_RX___.match @mixed_value
        if md
          __receive_matchdata md
        else
          _whine :invalid_tag_expression do
            "invalid {{ curr_prim }} expression: {{ ick_mixed_value }}"
          end
        end
      end

      def __receive_matchdata md

        s = md[ :val ]
        tag_value_x = s ? s.intern : true

        _yes = ! md[ :not ]

        tag_sym = md[ :tag ].intern

        _ = if _yes
          TagReducerPositive___.new tag_value_x, tag_sym
        else
          TagReducerNegative___.new tag_value_x, tag_sym
        end

        _red = ( @writable_client[ :reducers ] ||= MutableReducers__.new )
        _red.add_reducer_to_AND_group _, :_tags_

        ACHIEVED_
      end

      define_method :_whine, DEFINITION_FOR_THE_METHOD_CALLED_WHINE__

      def current_primary_symbol
        @primary.name_symbol
      end

      attr_reader :listener, :mixed_value
    end

    TagReducer__ = ::Class.new

    class TagReducerNegative___ < TagReducer__

      def initialize tag_value_x, tag_sym
        @to_proc = -> eg do
          h = eg.searchables.tagset_hash
          if h
            tag_value_x != h[ tag_sym ]
          else
            # (if the example has no tags and your criterion is
            # "not tag X", then the example matches the criterion).
            ACHIEVED_
          end
        end
        super
      end

      def positive_not_negative
        false
      end
    end

    class TagReducerPositive___ < TagReducer__

      def initialize tag_value_x, tag_sym
        @to_proc = -> eg do
          h = eg.searchables.tagset_hash
          if h
            tag_value_x == h[ tag_sym ]
          else
            # (if you're selecting for examples with a particular tag
            # and this example has no tags, it's not a match.)
            UNABLE_
          end
        end
        super
      end

      def positive_not_negative
        true
      end
    end

    class TagReducer__

      def initialize tag_value_x, tag_sym
        @mixed_tag_value = tag_value_x
        @tag_symbol = tag_sym
      end

      def finish
        true
      end

      attr_reader :mixed_tag_value, :tag_symbol, :to_proc
    end

    TAG_RX___ = /\A
      (?<not> ~ )?
      (?<tag> [-a-zA-Z_0-9]+ )  # or whatever
      (?: : (?<val> .+) )?
    \z/x

    choices_members.push :reducers

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
            # (the above is now tracked with [#009.E])
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

    class Example__  # (1st re-open)
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
        Here_::Models_::Specify.apply_if_not_defined test_context_class
      end
    end  # >>

    # === FEATURES POST-SUPPORT ===

    Something_via_ParsePrimary__ = ::Class.new Common_::Monadic

    class NonzeroPositiveInteger_via_ParsePrimary___ < Something_via_ParsePrimary__

      def _execute_
        case 0 <=> @integer
        when -1 ; @integer
        when 1 ; whine :digit_is_negative
        when 0 ; whine :digit_is_zero
        else ; never
        end
      end
    end

    class Something_via_ParsePrimary__

      def initialize o
        @parse_primary = o
      end

      def execute
        ok = true
        ok &&= __parse_integer
        ok &&= _execute_
        ok
      end

      def __parse_integer
        _  = @parse_primary.parse_integer
        store :@integer, _
      end

      def whine *a, &p
        @parse_primary.whine( *a, &p )
      end

      define_method :store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    Choices___ = ::Struct.new( * choices_members ) do

      def finish
        ok = true
        members.each do |mem|
          o = self[ mem ]
          o || next
          ok = o.finish
          ok || break  # assume emitted
        end
        ok && self
      end
    end

    # --

    class MutableReducers__

      # [#009.B]: the subject models a group of groups of reducers. (it's
      # not recursive; it's only those two dimensions.) in practice it
      # probably models line ranges and/or tags. assume it wouldn't have
      # been created unless it has at least one of these leaf nodes.

      # for our business needs we need the type of "union" for these groups
      # to be variously AND or OR depending on the level and/or business
      # category of the group. (the document provides detail and examples.)
      # however we want to keep these business values out of the code at the
      # subject level.

      # to this end the client declares the type of union it wants along
      # with an arbitrary business identifier to identify the group..

      def initialize
        @AND = Common_::Box.new
      end

      # ~ write

      def add_reducer_to_AND_group o, k
        touch_AND_group( k ).add_reducer o
      end

      def add_reducer_to_OR_group o, k
        touch_OR_group( k ).add_reducer o
      end

      def touch_AND_group k, & p
        _touch_AND_or_OR true, k, & p
      end

      def touch_OR_group k, & p
        _touch_AND_or_OR false, k, & p
      end

      def _touch_AND_or_OR and_not_or, k
        existing = @AND[ k ]
        if existing
          if and_not_or == existing.AND_not_OR
            existing
          else
            self._COVER_ME__you_cannot_change_the_behavior_of_an_existing_group__
          end
        else
          _x = yield if block_given?  # ick/meh
          new = BooleanGroup___.new _x, k, ( and_not_or ? :AND : :OR )
          @AND.add k, new
          new
        end
      end

      def finish
        ok = true
        @AND.each_value do |o|
          ok = o.finish
          ok || break  # assume emitted
        end
        ok
      end

      # ~ read

      def describe_into_under y, expag
        @AND.each_value do |o|
          o._describe_into_under_ y, expag
        end
        y
      end

      def to_proc  # assume only called once per invocation

        p_a = @AND.to_enum( :each_value ).map { |x| x.to_proc }
        if 1 == p_a.length
          p_a.fetch 0
        else
          __when_many p_a
        end
      end

      def __when_many p_a
        last = p_a.length - 1
        -> item do
          d = last
          begin
            yes = p_a.fetch( d )[ item ]
            yes || break
            d.zero? && break
            d -= 1
            redo
          end while above
          yes
        end
      end

      attr_reader :AND
    end

    class BooleanGroup___

      def initialize xx, k, and_not_or

        @_add_reducer = :__add_first_reducer

        @AND_not_OR = AND_OR_OR___.fetch and_not_or
        @business_category_symbol = k
        @passenger = xx
      end

      # -- write

      AND_OR_OR___ = { AND: true, OR: false }

      def add_reducer o
        send @_add_reducer, o
      end

      def __add_first_reducer o
        @reducers = []
        @_add_reducer = :__add_reducer
        send @_add_reducer, o
      end

      def __add_reducer o
        @reducers.push o ; nil
      end

      def finish
        __finish_any_passenger && __finish_items
      end

      def __finish_any_passenger
        if @passenger
          _ok = @passenger.finish_for self
          _ok  # #todo
        else
          ACHIEVED_
        end
      end

      def __finish_items
        ok = true
        @reducers.each do |red|
          ok = red.finish
          ok || break
        end
        ok
      end

      # -- read

      def to_proc
        if 1 == @reducers.length
          @reducers.first.to_proc
        else
          __when_many
        end
      end

      def __when_many
        p_a = @reducers.map { |rdcr| rdcr.to_proc }
        last = p_a.length - 1
        if @AND_not_OR
          -> item do  # do an AND - every item must be true
            d = last
            begin
              yes = p_a.fetch( d )[ item ]
              yes || break
              d.zero? && break
              d -= 1
              redo
            end while above
            yes
          end
        else
          -> item do  # do an OR - any item can be true; short circuit
            d = 0
            begin
              yes = p_a.fetch( d )[ item ]
              yes && break
              last == d && break
              d += 1
              redo
            end while above
            yes
          end
        end
      end

      attr_reader :AND_not_OR, :business_category_symbol, :passenger, :reducers
    end

    # --

    class CLI_PrimaryWriter___ < Common_::MagneticBySimpleModel

      # (we would like this to be agnostic but it's not quite..)

      attr_writer(
        :listener,
        :primary,
        :writable_client,
      )

      def execute
        p = @primary.custom_primary_writer
        if p
          __to_custom_writer p
        elsif @primary.is_flag
          if @primary.is_plural
            __writer_for_plural_flag
          else
            __writer_for_flag
          end
        elsif @primary.is_plural
          __writer_for_plural @primary
        else
          __writer_for_ordinary @primary
        end
      end

      def __to_custom_writer p
        -> x do
          if ! @primary.is_flag
            @__known_known = Common_::KnownKnown[ x ]
          end
          p[ self ]  # (result is false on failure)
          NIL
        end
      end

      def parse_integer
        # (look at API counterparts)
        Integer_via_ParsePrimary_[ self ]
      end

      def mixed_value
        @__known_known.value
      end

      def __writer_for_plural_flag
        k = @primary.name_symbol
        -> _ do
          @writable_client[ k ] ||= 0
          @writable_client[ k ] += 1
        end
      end

      def __writer_for_flag

        # for now we are KISS and not messing with the "[no-]" form: for now
        # all primaries `foo` start out with `@foo` being effectively `false`
        # (they should, anyway) and `--foo` always changes its value to
        # `true`. we can complicate this as necessary, but hopefully it
        # always fits that the negative/false/no/OFF state is the default
        # state, and the postive/true/yes/ON state is the marked state.

        # for such a flag the user may confuse it for an accumulating-type
        # flag (e.g advanced `--verbose` where more than one means something)
        # when it is not. for these cases we might whine on meaningless
        # repetition of the flag.

        k = @primary.name_symbol
        -> _ do
          if @writable_client[ k ].nil?
            @writable_client[ k ] = true
            NIL
          else
            ::Kernel._DESIGN_AND_COVER__maybe_warn__
          end
        end
      end

      def __writer_for_plural

        # weird fun: if any one item fails to normalize, "cancel"
        # the whole thing permanantly by falsing out the value.

        p = -> s do
          kn = _normalize s
          if kn
            ( @writable_client[ k ] ||= [] ).push kn.value
          else
            @writable_client[ k ] = false
            p = MONADIC_EMPTINESS_
          end
          NIL
        end
        -> s do
          p[ s ]
        end
      end

      def __writer_for_ordinary
        k = @primary.name_symbol
        no_repeat = -> _ do
          self._DESIGN_AND_COVER__maybe_warn__
        end
        p = -> s do
          kn = _normalize s
          if kn
            @writable_client[ k ] = kn.value
          else
            @writable_client[ k ] = nil  # propagate the error
          end
          p = no_repeat ; nil
        end
        -> s do
          p[ s ]
        end
      end

      def whine *a, &p
        # hi.
        __whine( *a, &p )
      end

      def current_primary_symbol
        @primary.name_symbol
      end

      define_method :__whine, DEFINITION_FOR_THE_METHOD_CALLED_WHINE__

      attr_reader :listener, :primary, :writable_client
    end

    # ==

    class Primary_  # < Common_::SimpleModel. a bespoke #[#fi-001] field class

      # -- write

      attr_writer(
        :name_symbol,
        :route,
      )

      def write_primary_by & p
        @custom_primary_writer = p
      end

      def be_plural
        @__plural_name_symbol = :"#{ @name_symbol.id2name }s"  # ..
        @_plural_name_symbol = :__plural_name_symbol
        @is_plural = true ; nil
      end

      def be_flag
        @is_flag = true ; nil
      end

      # -- read

      def plural_name_symbol  # assume `is_plural`
        send @_plural_name_symbol
      end

      def __plural_name_symbol
        @__plural_name_symbol  # hi.
      end

      attr_reader(
        :custom_primary_writer,
        :is_flag,
        :is_plural,
        :name_symbol,
        :route,
      )
    end

    # ===

    # ==

    Infinity_glyph___ = Lazy_.call() { '∞' }

    Here_ = self
  end
end
# :#tombstone-A.2: #eyeblood for old "tags receiver" that regexed ..
# :#tombstone-A.1: the previous: ( service, main run loop, rendering
#   functions, "runtime" (now "statistics"), `do_not_invoke!` )
