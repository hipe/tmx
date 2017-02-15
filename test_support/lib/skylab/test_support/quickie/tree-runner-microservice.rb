module Skylab::TestSupport

  module Quickie

    class TreeRunnerMicroservice < Common_::MagneticBySimpleModel  # [#006]

      # complementing [tmx] which is the first ever client to be purely
      # argument-scanner based, this is the first ever (in our universe)
      # "microservice" that is argument-scanner-based and multi-modality,
      # and plugin-based.
      #
      # all of this together allows us to test our "operations" (plugins)
      # without jumping thru the extra hoop of running it through a CLI..
      #
      # formal introduction and developer notes are in the document.

      class << self
        def define & p
          super( & p ).__prepare
        end
      end  # >>

      # ==

      The_eventpoint_graph___ = Lazy_.call do

        Quickie::Eventpoint_ = Home_.lib_.task::Eventpoint  # eek/meh

        _hi = Eventpoint_.define_graph do |o|

          o.add_state :beginning,
            :can_transition_to, [ :files_stream, :finished ]

          o.add_state :files_stream,
            :can_transition_to, [ :finished ]

          o.add_state :finished

          o.beginning_state :beginning
        end
        _hi  # #todo
      end

      # ==

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

          scn = Common_::Scanner.via_array(
            remove_instance_variable( :@__path ).steps )

          ok = true
          begin
            step = scn.gets_one
            scn.no_unparsed_exists && break
            ok = __invoke_nonfinal_plugin step
          end while ok

          if ok
            __invoke_final_plugin step
          end

          # when this fails we must result in NIL (not false) per [#ze-026.1]
        end

        def __invoke_nonfinal_plugin step
          sct = _struct_via_step step
          sct and __receive_plugin_product sct
        end

        def __invoke_final_plugin step
          sct = _struct_via_step step
          sct and sct.final_result
        end

        def _struct_via_step step

          hi, d = step.mixed_task_identifier
          :_hello_my_plugin_ == hi || fail

          _plugin = @lazy_index.dereference_plugin d

          _sct = _plugin.invoke step.formal_transition
          _sct  # #todo
        end

        # -- EXPERIMENTAL - see [#here.B]

        def DEREFERENCE_PLUGIN sym
          @lazy_index.dereference_plugin_via_normal_symbol sym
        end

        # -- receiving plugin products

        def __receive_plugin_product sct
          send PROCESS_RESPONSE___.fetch( sct.category_symbol ), * sct.to_a
        end

        PROCESS_RESPONSE___ = {
          datapoint: :__process_datapoint,
          stop_now: :__stop_now,
        }

        def __stop_now
          # assume emitted
          NIL
        end

        def __process_datapoint x, name_sym
          send PROCESS_DATAPOINT___.fetch( name_sym ), x
        end

        PROCESS_DATAPOINT___ = {
          test_file_path_streamer: :__process_test_file_path_streamer,
          unparsed_tag_expressions: :__process_unparsed_tag_expressions,
        }

        def __process_unparsed_tag_expressions x
          _safe_write :@_unparsed_tags, x
        end

        def release_any_unparsed_tags__
          if instance_variable_defined? :@_unparsed_tags
            remove_instance_variable :@_unparsed_tags
          end
        end

        def __process_test_file_path_streamer x
          _safe_write :@test_file_path_streamer, x
        end

        def release_test_file_path_streamer_
          remove_instance_variable :@test_file_path_streamer
        end

        def _safe_write ivar, x
          if instance_variable_defined? ivar
            orig_x = instance_variable_get ivar
          end
          orig_x.nil? || self._EVENTPOINT_GRAPH_SANITY
          instance_variable_set ivar, x
          ACHIEVED_
        end

        # ~

        def __resolve_execution_path

          scn = @lazy_index.to_scanner_of_offsets_of_plugins_with_pending_execution

          _graph = The_eventpoint_graph___[]

          _pool = Eventpoint_::AgentProfile::PendingExecutionPool.define do |pool|

            until scn.no_unparsed_exists
              d = scn.gets_one
              _plugin = @lazy_index.dereference_plugin d
              profile = _plugin.release_agent_profile
              if ! profile
                # hi: #coverpoint-2-4 is about how a single plugin (instance)
                # can fulfill multiple argument expressions in one invocation
                next
              end
              pool.add_pending_task [ :_hello_my_plugin_, d ], profile
            end
          end

          _maybe_path = Eventpoint_::Path_via_PendingExecutionPool_and_Graph.call_by do |o|

            o.default_finisher_by = method :__maybe_default_finisher
            o.pending_execution_pool = _pool
            o.graph = _graph
            o.say_plugin_by = method :__say_plugin
            o.listener = @listener
          end

          _store :@__path, _maybe_path
        end

        def __maybe_default_finisher sym

          # supreme hack for the convenience of the most typical use case:
          # if we didn't get to a finished state but we *did* get to the
          # `files_stream` state, then "nudge" it to a finished state by
          # telling the pathfinding to use the `run_files` plugin. this in
          # combination with the `default_primary_symbol` of `path` is what
          # allows us to provide only one argument (a path) and still work.

          if :files_stream == sym
            d = @lazy_index.offset_of_touched_plugin_via_normal_symbol :run_files
            _pi = @lazy_index.dereference_plugin d
            _profile = _pi.release_agent_profile
            _eek = [ [ :_hello_my_plugin_, d ], _profile ]  # [#ta-013] will probably improve
            _eek  # hi. #todo
          end
        end

        def __say_plugin my_tuple, m=:prim, expag

          my_tuple.first == :_hello_my_plugin_ || fail
          _nat_key = @lazy_index.natural_key_via_offset my_tuple.last
          sym = _nat_key.gsub( DASH_, UNDERSCORE_ ).intern

          if :ick == m
            m = :ick_prim
          end

          expag.send m, sym
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
          yes &&= as.scan_primary_symbol_softly
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

            # if you parsed one primary initially (softly), bogey down
            @omni.flush_to_lookup_current_and_parse_remaining_primaries

          elsif @argument_scanner.no_unparsed_exists

            # (no args will always fail (right?) but ride along.. #coverpoint-2-1)
            ACHIEVED_

          else
            self._COVER_ME__see_tombstone_for_ideas__  # (was #tombstone-C)
          end
        end

        def __PARSE_HEAD_VIA_PLUGIN primary_found

          _custom_load_ticket = primary_found.trueish_item_value
          _custom_load_ticket.HELLO_LOAD_TICKET

          d = @lazy_index.offset_of_touched_plugin_via_user_value _custom_load_ticket
          pi = @lazy_index.dereference_plugin d
          ok = pi.parse_argument_scanner_head
          if ok
            @lazy_index.enqueue d
          end
          ok
        end

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

        # ~ services for above

        def test_filename_tail
          Home_.spec_rb
        end

        # ~

        def __init_operator_branch

          @_MTk = Zerk_lib_[]::MicroserviceToolkit

          @_has_result = false  # might be temporary
          @operator_branch =
            Zerk_::ArgumentScanner::OperatorBranch_via_AutoloaderizedModule.
          define do |o|
            o.module = Here_::Plugins
          end
          NIL
        end

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

        # --

        attr_reader(
          :argument_scanner,
          :lazy_index,
          :listener,
          :operator_branch,
        )
      # -

      # ==

      module Quickie::Responses_  # [#here.A] realise local conventions for plugin communication

        class << self
          def the_stop_response
            @___the_stop_response ||= TheStopResponse___.new
          end
        end  # >>

        class TheStopResponse___
          # interrupts the execution of the eventpoint path early, error probably
          def category_symbol
            :stop_now
          end
          def to_a
            NOTHING_
          end
        end

        FinalResult = ::Struct.new :final_result

        Datapoint = ::Struct.new :value, :name_symbol do
          def category_symbol
            :datapoint
          end
        end
      end

      # ==

      Require_plugin_ = Lazy_.call do
        Plugin_ = Home_.lib_.plugin ; nil
      end

      # ==
    end
  end
end
# :#tombstone-C: (probably temporary)
# :#tombstone-B: replaced legacy eventpoint graph with beginnings of new
# :#history-A: begin overhaul to use new eventpoint
# #tombstone: `function_chain`
