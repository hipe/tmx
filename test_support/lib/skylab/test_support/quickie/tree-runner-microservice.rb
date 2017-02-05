module Skylab::TestSupport

  module Quickie

    class TreeRunnerMicroservice < Common_::MagneticBySimpleModel

      # complementing [tmx] which is the first ever client to be purely
      # argument-scanner based, this is the first ever (in our universe)
      # "microservice" that is argument-scanner-based and multi-modality,
      # and plugin-based.
      #
      # all of this together allows us to test our "operations" (plugins)
      # without jumping thru the extra hoop of running it through a CLI..

      class << self
        def define & p
          super( & p ).__prepare
        end
      end  # >>

    if false
    module Eventpoint_Graph___

      Home_.lib_.task::Eventpoint::Graph[ self ]

      BEGINNING = eventpoint

      TEST_FILES = eventpoint do
        from BEGINNING
      end

      CULLED_TEST_FILES = eventpoint do
        from TEST_FILES
      end

      BEFORE_EXECUTION = eventpoint do
        from CULLED_TEST_FILES
      end

      EXECUTION = eventpoint do
        from BEFORE_EXECUTION
      end

      FINISHED = eventpoint do
        from BEGINNING
        from CULLED_TEST_FILES
        from EXECUTION
      end
    end
    # ->
      POSSIBLE_GRAPH = Eventpoint_Graph___.possible_graph

    end  # if false

      # -
        attr_writer(
          :argument_scanner,
          :listener,
        )

        def __prepare  # makes testing easier to do this outside of execute
          __init_operator_branch
          __init_plugin_lazy_index
          @listener ||= @argument_scanner.listener
          self
        end

        def execute
          if __parse_arguments
            if @_has_result
              remove_instance_variable :@_result
            elsif __resolve_execution_path
              __flush_execution
            end
          end
        end

        def __flush_execution

          # (later we would be working from an execution path.
          # #only-until-eventpoint, we work directly from the queue..)

          scn = @lazy_index.to_scanner_of_offsets_of_plugins_with_pending_execution
          if scn.no_unparsed_exists
            __when_empty_empty_execution_path
          else
            __execute_these scn
          end
        end

        def __when_empty_empty_execution_path
          # #only-until-eventpoint
          @listener.call :error, :expression, :etc_something do |y|
            y << "nothing gets it to the endpoint (STUB MESSAGE)"
          end
          SOFT_UNABLE_
        end

        def __execute_these scn
          ok = ACHIEVED_
          begin
            _plugin = @lazy_index.dereference_plugin scn.gets_one
            ok = _plugin.execute
            ok || break
          end until scn.no_unparsed_exists
          ok ? SOFT_ACHIEVED_ : SOFT_UNABLE_
        end

        def __resolve_execution_path
          # #only-until-eventpoint
          ACHIEVED_
        end

        # TL;DR: never don't ping
        #
        # the cost of a `ping` in this manner is that it takes a few lines
        # of up-front finagling to peek the scan and see if there's a head
        # primary that is this particular symbol (we don't want to maintain
        # a dedicated file for a ping) before we move on to handling the
        # arguments "purely" via our plugin tree.
        #
        # but the advantage of such an operation is that we can test and
        # confirm (either as humans or as test suites) that this
        # microservice can be reached from the "outside" (i.e that the
        # invocation model builds), that the scanner scans (for two modes)
        # and that the listener listens (again for two modes) and that maybe
        # a result happens; all with an operation whose responsibility is
        # limited to only these concerns.

        def __parse_arguments

          as = @argument_scanner
          yes = ! as.no_unparsed_exists
          yes &&= as.parse_primary_softly
          if yes && :ping == as.current_primary_symbol
            __express_ping
          else
            __parse_arguments_via_omni
          end
        end

        def __express_ping
          @listener.call :info, :expression, :ping do |y|
            y << "the quickie tree-runner microservice says #{ em 'hello' }"
          end
          @_has_result = true
          @_result = :_ping_from_quickie_tree_runner_microservice_
          ACHIEVED_
        end

        def __parse_arguments_via_omni

          @omni = @_MTk::ParseArguments_via_FeaturesInjections.define do |o|
            o.argument_scanner = @argument_scanner
            o.add_lazy_primaries_injection_by do |inj|
              inj.primaries = @operator_branch
              inj.parse_by = method :__PARSE_HEAD_VIA_PLUGIN
            end
          end

          if @argument_scanner.has_current_primary_symbol
            @omni.flush_to_lookup_current_and_parse_remaining_primaries
          elsif @argument_scanner.no_unparsed_exists
            ACHIEVED_
          else
            _no = @argument_scanner.parse_primary
            _no == UNABLE_ || fail
            _no
          end
        end

        def __PARSE_HEAD_VIA_PLUGIN primary_found

          _custom_load_ticket = primary_found.trueish_item_value
          _custom_load_ticket.HELLO_LOAD_TICKET

          d = @lazy_index.offset_of_touched_plugin_via_user_value _custom_load_ticket
          pi = @lazy_index.dereference_plugin d
          remove_instance_variable :@__only_one_plugin_mutex  # #only-until-eventpoint
          ok = pi.parse_argument_scanner_head
          if ok
            @lazy_index.enqueue d
          end
          ok
        end

    if false
      def initialize dae

        dae.receive_mixed_client_ self

        @_daemon = dae
        @infostream = nil
        @paystream = nil
        @_plugins = nil
        @program_moniker = nil
        @x_a_a = nil
        @y = nil
      end

      def _svc
        @_daemon  # #hacks-only
      end

      attr_writer :do_recursive, :program_moniker

      def set_three_streams _, o, e
        @paystream = o ; @infostream = e
        @y = nil
      end

      def receive_argv__ argv

        @_do_execute = false

        ok = __load_plugins
        ok &&= __via_plugins_resolve_signatures argv
        ok &&= __check_if_ARGV_is_completely_parsed_via_sigs
        ok &&= __resolve_path_via_trueish_sigs
        ok &&= __emit_each_eventpoint_to_all_subscribed_plugins

        if @_do_execute
          bc = __bound_call_for_test_execution
          if bc
            bc.receiver.send bc.method_name, * bc.args, & bc.block
          else
            bc
          end
        else
          ok
        end
      end

      # -- services for dependencies

      # ~ test path, execution writers

      def yes_do_execute__
        @_do_execute = true
      end

      def replace_test_path_s_a path_s_a
        @_plugins[ :run_recursive ].dependency_.replace_test_path_s_a path_s_a
      end

      # ~ test-path readers

      def get_test_path_array  # #reach-down
        @_plugins[ :run_recursive ].dependency_.get_any_test_path_array
      end

      def to_test_path_stream
        @_plugins[ :run_recursive ].dependency_.to_test_path_stream
      end

      # ~ UI-related readers

      def program_moniker
        @program_moniker or ::File.basename $PROGRAM_NAME
      end

      def moniker_
        "#{ program_moniker } "
      end

      # ~ IO-related readers

      def y
        @y ||= ::Enumerator::Yielder.new( & infostream_.method( :puts ) )
      end

      def infostream_
        @infostream || @_daemon.infostream_
      end

      def paystream_
        @paystream || @_daemon.paystream_  # may be mounted under a supernode
      end

      # ~ misc

      def add_iambic x_a
        @x_a_a ||= []
        @x_a_a.push x_a ; nil
      end

      attr_reader :x_a_a

      # -- service API for performers

      def receive_test_context_class__ tcc  # from an outermost runtime
        # when the files start loading, this is the hookback
        @executor.receive_test_context_class___ tcc
      end

    private

      # -- UI

      def invite_string
        "see '#{ program_moniker } --help'"
      end

      def argument_error argv

        @y << "#{ moniker_ }aborting because none of the plugins or #{
          }loaded spec files processed the argument(s) - #{
          }#{ argv.map( & :inspect ) * SPACE_ }"

        @y << invite_string

        NIL_
      end

      def usage
        @_plugins[ :help ].dependency_.usage
        NIL_
      end

      # -- plugin mechanics

      def __load_plugins

        @_plugins and self._STATE_FAILURE

        o = Home_.lib_.plugin::BaselessCollection.new
        o.eventpoint_graph = POSSIBLE_GRAPH
        o.modality_const = :CLI
        o.plugin_services = self
        o.plugin_tree_seed = Here_::Plugins

        ok = o.load_all_plugins
        ok and begin @_plugins = o ; ACHIEVED_ end
      end

      def __via_plugins_resolve_signatures argv

        if '--help' == argv[0]  # while #open [#030]
          argv[0] = '-help'
        end

        frozen_argv = argv.dup.freeze

        a = []

        @_plugins.accept do | de |
          a.push de.prepare frozen_argv
        end

        if ! a.any?  # not a.lenght.zero?
          if frozen_argv.length.zero?
            @y << "nothing to do."
            @y << invite_string
            NIL_
          else
            argument_error argv
          end
        else
          @_sig_a = a ; KEEP_PARSING_
        end
      end

      def __check_if_ARGV_is_completely_parsed_via_sigs  # assume any

        scn = Common_::Scanner.via_array @_sig_a

        sig = Next_trueish__[ scn ]   # assume one

        xtra_a = ::Array.new sig.input.length, true

        begin

          sig.input.each_with_index do |x, idx|  # ( bitwise OR )
            if x.nil?
              xtra_a[ idx ] &&= nil
            elsif true == xtra_a[ idx ]
              xtra_a[ idx ] = x
            end
          end

          sig = Next_trueish__[ scn ]

          sig or break
          redo
        end while nil

        if xtra_a.any?
          argument_error xtra_a.compact
        else
          ( @_trueish_sig_a = remove_instance_variable( :@_sig_a ) ).compact!
          ACHIEVED_
        end
      end

      Next_trueish__ = -> scn do
        begin
          if scn.no_unparsed_exists
            break
          end
          x = scn.gets_one
          x and break
          redo
        end while nil
        x
      end

      def __resolve_path_via_trueish_sigs

        @_graph = POSSIBLE_GRAPH

        wv = @_graph.reconcile @y, :BEGINNING, :FINISHED, @_trueish_sig_a
        if wv
          @_path = wv.value_x
          ACHIEVED_
        else
          @y << "aborting because of the above. #{ invite_string }"
          NIL_
        end
      end

      def __emit_each_eventpoint_to_all_subscribed_plugins

        st = @_path.to_stream
        sym = :BEGINNING
        begin

          ok = ___emit_eventpoint_to_all_subscribed_plugins sym
          ok or break

          pred = st.gets
          if ! pred
            break
          end

          sym = pred.after_symbol

          redo
        end while nil
        ok
      end

      def ___emit_eventpoint_to_all_subscribed_plugins eventpoint_sym

        ep = @_graph.fetch_eventpoint eventpoint_sym

        ok = true

        @_plugins.accept do | de |

          sig = de.signature
          sig or next

          if ! sig.subscribed_to? ep
            next
          end

          x = de.eventpoint_notify ep
          if false == x
            ok = x
            break
          end
        end
        ok
      end

      def __bound_call_for_test_execution

        o = Here_::Sessions_::Execute.new(

          @y, get_test_path_array, @_daemon.program_name_string_array_

        ) do | q |

          if @x_a_a
            __set_quickie_options q
          end
        end

        o.be_verbose = @_plugins[ :run_recursive ].dependency_.be_verbose
        @executor = o
        o.produce_bound_call
      end

      def __set_quickie_options quickie
        @x_a_a.each do |x_a|
          quickie.with_iambic_phrase x_a
        end
        NIL_
      end
    end  # if false

        # -- initting the plugins

        def __init_plugin_lazy_index
          Require_plugin_[]
          @lazy_index = Plugin_::Models::LazyIndex.define do |o|

            o.operator_branch = @operator_branch

            o.construct_plugin_by = method :__construct_plugin_via_class
          end
          NIL
        end

        def __construct_plugin_via_class cls
          cls.new { self }
        end

        def __init_operator_branch

          Require_zerk_[]
          @_MTk = Zerk_::MicroserviceToolkit

          @_has_result = false  # might be temporary
          @__only_one_plugin_mutex = nil   # #only-until-eventpoint
          @operator_branch =
            Zerk_::ArgumentScanner::OperatorBranch_via_AutoloaderizedModule.
          define do |o|
            o.module = Here_::Plugins
          end
          NIL
        end

        # --

        attr_reader(
          :argument_scanner,
          :lazy_index,
          :listener,
          :operator_branch,
        )
      # -

      # ==

      Require_plugin_ = Lazy_.call do
        Plugin_ = Home_.lib_.plugin ; nil
      end

      # ==

      SOFT_ACHIEVED_ = nil  # so now this is purely for self-documenting
      SOFT_UNABLE_ = nil  # one day we might want `false` to mean `no`

      # ==
    end
  end
end
# :#history-A: begin overhaul to use new eventpoint
# #tombstone: `function_chain`
