module Skylab::TestSupport

  module Quickie

    module API

      # NOTE:
      #
      #   - this node started life as a "performer" (session or actor) that
      #     loaded test files for the quickie recursive runner.
      #
      #   - it then evolved to constitute the implementation of the API
      #     invocation-model for "one-file", an effort whose primary
      #     objective is to make testing unawkward by obviating a CLI there.
      #
      #   - now (ironically or not) it also houses the CLI *for* the
      #     recursive runner.
      #
      #   - also it now holds the API invocation-model for the recursive
      #     runner.

      class << self

        def invocation_via_argument_array a, & p
          API_for_RecursiveRunner___.new p, a
        end
      end  # >>

      # ==

      class CLI_for_RecursiveRunner

        class << self
          def call argv, i, o, e, pn_a
            new( argv, i, o, e, pn_a ).execute
          end
          alias_method :[], :call
          # private :new  #testpoint
        end  # >>

        def initialize argv, i, o, e, pn_a
          @__ARGV = argv
          @__program_name_string_array = pn_a
          @_stderr = e
          @__stdout = o
        end

        def execute

          Require_zerk_[]
          @_CLI_Mtk = Zerk_::CLI::MicroserviceToolkit

          _argv = remove_instance_variable :@__ARGV

          _as = @_CLI_Mtk::ArgumentScanner_via_ArgumentArray.call(
            _argv, & method( :__receive_emission ) )

          __init_listener

          @_did_err = false

          x = Here_::TreeRunnerMicroservice.call_by do |o|
            o.argument_scanner = _as
          end

          if @_did_err
            GENERIC_ERROR_EXITSTATUS_
          elsif x.nil?
            @_CLI_Mtk::SUCCESS_EXITSTATUS
          else
            :_ping_from_quickie_tree_runner_microservice_ == x || self._DO_ME
            @_CLI_Mtk::SUCCESS_EXITSTATUS
          end
        end

        def __receive_emission * chan, & p

          if :warning == chan.first

            # the remote library doesn't speak warnings, for now.

            chan[0] = :info

            # for now we'll upgrade warnings to errors (which may have
            # limited effect)..

            @_did_err = true
          end

          @__plain_listener[ * chan, & p ]
        end

        def __init_listener

          @__plain_listener = @_CLI_Mtk::Listener_via.call_by do |o|

            o.receive_did_err_by = -> { @_did_err = true }
            o.resource_by = method :__resource
            o.stderr = @_stderr
          end
          NIL
        end

        def __resource k
          send RESOURCES___.fetch k
        end

        RESOURCES___ = {
          injected_client_resource: :__injected_client_resource,
          line_downstream_for_help: :__line_downstream_for_help,
        }

        def __injected_client_resource

          _er = CLI_ExpressionResources_.define do |o|
            o.stderr = @_stderr
            o.stdout = remove_instance_variable :@__stdout
          end

          _ic = CLI_InjectedClient_.define do |o|
            o.CLI_expression_resources = _er
          end

          _ic  # hi. #todo
        end

        def __line_downstream_for_help
          @_stderr
        end
      end

      # ==

      class API_for_RecursiveRunner___

        # (we need a dedicated API invocation client separate from the
        # tree runner microservice only because we to do the reconciliation
        # of resources like "line downstream for help" in a way custom for
        # API, in what we used to call #masking..)

        def initialize p, a

          as = No_deps_zerk_[]::API_ArgumentScanner.new a, & p

          @__tree_runner_microservice = Here_::TreeRunnerMicroservice.define do |o|
            o.argument_scanner = as
            o.listener = method :__receive_emission
          end
          # (above ivar name is a #testpoint)

          @argument_scanner = as
        end

        def execute
          _hi = remove_instance_variable( :@__tree_runner_microservice ).execute
          _hi  # #todo
        end

        def __receive_emission * chan, & p
          if :resource == chan.first
            _something = receive_resource_request p, chan
            _something  # #hi.
          else
            _maybe_line_medium = @argument_scanner.listener[ * chan, & p ]
            _maybe_line_medium  # #hi.
          end
        end

        def receive_resource_request _p, chan
          send RESOURCES___.fetch( chan.fetch 1 ), * chan[ 2..-1 ]
        end

        RESOURCES___ = {
          injected_client_resource: :__injected_client_resource,
          line_downstream_for_help: :__line_downstream_for_help,
        }

        def __injected_client_resource
          # (this is the default client to use in an API call, which would
          # suggest that we could result in nothing to the same effect. but
          # the plugin caller needs something trueish.)
          API_InjectedClient__
        end

        def __line_downstream_for_help
          @argument_scanner.listener.call :error, :expression, :mode_mismatch do |y|
            y << "no 'help' for API client"
          end
          NOTHING_
        end
      end

      # ==

      class InjectedClient_via_Listener_and_Arguments < Common_::Dyadic  # 1x

        def initialize p, a
          @__arguments_array = a
          @_listener = p

          @injected_client = nil
          @load_tests_by = nil
        end

        def execute
          if __resolve_choices
            __WEE
          end
        end

        def __WEE

          _cx = remove_instance_variable :@__choices
          _xx = __injected_clienter
          p = remove_instance_variable :@load_tests_by

          _xx.define do |o|

            if p
              o.load_tests_by = p
            end

            o._choices_ = _cx
            o._listener_ = @_listener
          end
        end

        def __injected_clienter
          _xx = remove_instance_variable :@injected_client
          _xx || API_InjectedClient__
        end

        def _xxx_GET_RID_OF_ME
          ok = nil
          API_InjectedClient__.define do |o|
            @_client = o
            ok = __resolve_choices
            if ok
              o._choices_ = @__choices
              o._listener_ = @_listener
            end
          end
          ok && @_client
        end

        def __resolve_choices
          @_formal_primaries_cache = {}
          @_formal_primaries_hash = {}
          _cx = Choices_via_AssignmentsProc_and_Client_.call self do |cx|
            __write_choices_into cx
          end
          _store :@__choices, _cx
        end

        def __write_choices_into cx
          @_writable_CHOICES = cx.writable_choices
          cx.write_formal_primaries_into self
          __add_bespoke_primaries
          ok = __read_arguments
          ok &&= __check_requireds
          remove_instance_variable :@_writable_CHOICES
          ok
        end

        def __add_bespoke_primaries
          _add_bespoke_primary :injected_client
          _add_bespoke_primary :load_tests_by
          NIL
        end

        def _add_bespoke_primary sym
          add_primary sym do |o|
            yield o if block_given?
            o.route = :_this_is_an_API_specific_primary_
          end
          NIL
        end

        def add_primary k, & p
          @_formal_primaries_hash[ k ] = p
          NIL
        end

        def __read_arguments

          @_scanner = Common_::Scanner.
            via_array remove_instance_variable :@__arguments_array

          ok = true
          until @_scanner.no_unparsed_exists
            ok = __process_one_primary
            ok || break
          end
          ok
        end

        def __check_requireds
          if @load_tests_by
            ACHIEVED_
          else
            __whine_about_missing_required [ :load_tests_by ]
          end
        end

        def __whine_about_missing_required sym_a
          @_listener.call :error, :expression, :missing_requireds do |y|
            y << "missing required argument(s): (#{ sym_a * ', ' })"
          end
          UNABLE_
        end

        def __process_one_primary
          fo = __gets_one_formal_primary
          _ok = send ROUTE___.fetch( fo.route || DEFAULT_ROUTE__ ), fo
          _ok  # #todo
        end

        ROUTE___ = {
          _this_is_an_agnostic_primary_: :__process_agnostic_primary,
          _this_is_an_API_specific_primary_: :__process_API_specific_primary,
        }

        DEFAULT_ROUTE__ = :_this_is_an_agnostic_primary_

        def __process_API_specific_primary fo
          _ok = ProcessOne_API_PrimaryValue__.call_by do |o|
            o.listener = @_listener
            o.primary = fo
            o.scanner = @_scanner
            # o.writable_client = @_client
            o.writable_client = self
          end
          _ok  # #todo
        end

        attr_accessor(
          :injected_client,
          :load_tests_by,
        )

        def __process_agnostic_primary fo
          _ok = ProcessOne_API_PrimaryValue__.call_by do |o|
            o.listener = @_listener
            o.primary = fo
            o.scanner = @_scanner
            o.writable_client = @_writable_CHOICES
          end
          _ok  # #todo
        end

        # --

        def __gets_one_formal_primary
          k = @_scanner.gets_one
          @_formal_primaries_cache.fetch k do
            fo = __build_formal_primary k
            @_formal_primaries_cache[ k ] = fo
            fo
          end
        end

        def __build_formal_primary k
          p = @_formal_primaries_hash.fetch k
          @_formal_primaries_hash.delete k
          API_Primary___.define do |o|
            o.name_symbol = k
            p && p[ o ]
          end
        end

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
      end

      # ==

      class API_InjectedClient__ < Common_::SimpleModel

        def initialize
          yield self
          @_begin_branch_node = :__begin_branch_node_initially
          @_current_example_passed = true
          @_expiration_counter = 0
          @_has_example_on_deck = false
        end

        attr_writer(
          :_choices_,
          :_listener_,
          :load_tests_by,
        )

        def RECEIVE_RUNTIME_ rt

          # unlike under onefile CLI, with an API call you have to
          # do the extra work of loading the files..

          svc = rt.dereference_quickie_service_

          svc.begin_irreversible_one_time_compound_mode_

          _x = @load_tests_by[ rt ]  # all 3 major players are accessible by runtime

          # (to have the above result be meaningful would be really annoying near tests..)

          _stats = svc.end_irreversible_one_time_compound_mode_
          _stats  # #todo
        end

        def at_beginning_of_test_run( * )
          NOTHING_  # API does not emit back out the search criteria
        end

        def begin_branch_node d, ctx
          send @_begin_branch_node, d, ctx
        end

        def __begin_branch_node_initially d, ctx
          d.zero? || self._SANITY
          ctx.description && self._SANITY
          @_branch_stack = []
          @_expected_leaf_depth = 1
          @_begin_branch_node = :__begin_branch_node_normally
          NIL
        end

        def __begin_branch_node_normally d, ctx
          if ctx.is_pending
            NOTHING_  # hi.
          elsif @_expected_leaf_depth == d
            _flush_any_example_on_deck
            @_branch_stack.push ctx.description
            @_expected_leaf_depth += 1
          else
            # (when branch is shallower, flush any pending guys THEN the rest)
            _flush_any_example_on_deck
            @_branch_stack[ d - 1 ] = ctx.description
            @_branch_stack[ d .. -1 ] = EMPTY_A_
            @_expected_leaf_depth = d + 1
          end
        end

        def begin_leaf_node d, eg
          _flush_any_example_on_deck
          @_example_on_deck = eg
          @_has_example_on_deck = true
          case @_expected_leaf_depth <=> d

          when 0  # (if the leaf is as deep as is expected, leaf stack as-is)
            NOTHING_

          when 1 # (when leaf is shallower, chop that much off the top of the stack)
            @_branch_stack[ ( d - 1 ) .. -1 ] = EMPTY_A_
            @_expected_leaf_depth = d
          else

            # (leaf should never be deeper than is expected)
            self._SANITY
          end
          NIL
        end

        def receive_failure _, __
          # (meh)
          @_current_example_passed = false
          NIL
        end

        def receive_pass _
          NOTHING_
        end

        def receive_pending
          _clear_example
        end

        def receive_skip
          _clear_example
        end

        def _clear_example
          remove_instance_variable :@_example_on_deck
          @_has_example_on_deck = false
          NIL
        end

        def flush
          _flush_any_example_on_deck  # hi.
        end

        def _flush_any_example_on_deck
          @_has_example_on_deck && _flush_example_on_deck
          NIL
        end

        def _flush_example_on_deck
          @_has_example_on_deck = false
          d = ( @_expiration_counter += 1 )
          yes = @_current_example_passed
          @_current_example_passed = true
          @_listener_.call :data, :example do
            if d == @_expiration_counter  # (otherwise the event is stale - you get nothing)
              __example yes
            end
          end
          remove_instance_variable :@_example_on_deck
          NIL
        end

        def __example yes

          _dstack = [ * @_branch_stack, * @_example_on_deck.description ]
          API_Example___.new yes, _dstack
        end

        attr_reader(
          :_choices_,
          :load_tests_by,
        )
      end

      API_Example___ = ::Struct.new :passed, :description_stack

      # ==

      class ProcessOne_API_PrimaryValue__ < Common_::MagneticBySimpleModel

        attr_writer(
          :listener,
          :primary,
          :scanner,
          :writable_client,
        )

        def execute
          p = @primary.custom_primary_writer
          if p
            __via_custom_primary_writer p
          elsif @primary.is_flag
            if @primary.is_plural
              _write _read + 1
            else
              _write true
            end
          elsif @primary.is_plural
            __process_plural
          else
            __process_ordinary
          end
        end

        def __via_custom_primary_writer p
          # #experimental - interface is VERY in flux..
          if ! @primary.is_flag
            x = @scanner.gets_one
            # (for now, here we convert all symbols to strings so that
            #  strings are the modality agnostic lingua-franca..)
            if x.respond_to? :id2name
              x = x.id2name
            end
            @__known_known = Common_::Known_Known[ x ]
          end
          _ok = p[ self ]
          _ok  # #todo
        end

        # ~ for above:

        def parse_integer
          # make testing CLI-style arguments easier by parsing strings the same way here
          x = mixed_value
          if x.respond_to? :bit_length
            x
          else
            Integer_via_ParsePrimary_[ self ]
          end
        end

        def current_primary_symbol
          @primary.name_symbol
        end

        attr_reader(
          :listener,
          :primary,
          :writable_client,
        )

        # ~

        def mixed_value
          @__known_known.value_x
        end

        def __process_plural
          kn = _normal_knownness
          if kn
            _read.push kn.value_x
            ACHIEVED_
          else
            kn
          end
        end

        def __process_ordinary
          x = _read
          if x.nil?
            kn = _normal_knownness
            kn and _write kn.value_x
          else
            self._COVER_ME__policy_for_clobber__
          end
        end

        def _normal_knownness
          # (leaving room for numerizers etc)
          x = @scanner.gets_one  # this could be fancier, but not today
          # ..
            Common_::Known_Known[ x ]
        end

        def _write x
          @writable_client.send :"#{ @primary.name_symbol }=", x
          ACHIEVED_
        end

        def _read
          @writable_client.send @primary.name_symbol
        end

        define_method :whine, DEFINITION_FOR_THE_METHOD_CALLED_WHINE__
      end

      # ==

      class API_Primary___ < Primary_

        def didactics_by
          # didactics are a CLI thing. API doesn't have help screens.
          NOTHING_
        end
      end

      # ==

      class ExpressionAgent

        class << self
          def instance
            @___instance ||= new
          end
          private :new
        end  # >>

        alias_method :calculate, :instance_exec

        def ick x
          x.inspect
        end

        def prim sym
          "'#{ sym }'"
        end
      end

      # ==

      GENERIC_ERROR_EXITSTATUS_ = 113  # 'q'.ord

      # ==
    end  # API
  end
end
# :#tombstone-A: #temporary
# #history: began to splice brand new API client into legacy file
