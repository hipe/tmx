module Skylab::TestSupport

  module Quickie

    module API

      # ==

      class API_InjectedClient_via_Listener_and_Arguments < Common_::Dyadic

        def initialize p, a
          @__arguments_array = a
          @_listener = p
        end

        def execute
          ok = nil
          API_InjectedClient___.define do |o|
            @_client = o
            ok = __resolve_choices
            if ok
              o._choices_ = @__choices
              o._listener = @_listener
            end
          end
          ok && @_client
        end

        def __resolve_choices
          @_formal_primaries_cache = {}
          @_formal_primaries_hash = {}
          _cx = Choices_via_AssignmentsProc_and_Client_.call self do |cx|
            @_writable_CHOICES = cx.writable_choices
            cx.write_formal_primaries_into self
            __add_bespoke_primaries
            __parse_arguments
          end
          remove_instance_variable :@_writable_CHOICES
          _store :@__choices, _cx
        end

        def __add_bespoke_primaries
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

        def __parse_arguments

          @_scanner = Common_::Scanner.
            via_array remove_instance_variable :@__arguments_array

          ok = true
          until @_scanner.no_unparsed_exists
            ok = __process_one_primary
            ok || break
          end

          ok && __check_requireds
        end

        def __check_requireds
          if @_client.load_tests_by
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
            o.writable_client = @_client
          end
          _ok  # #todo
        end

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

      class API_InjectedClient___ < Common_::SimpleModel

        def initialize
          yield self
          @_begin_branch_node = :__begin_branch_node_initially
          @_current_example_passed = true
          @_expiration_counter = 0
          @_has_example_on_deck = false
        end

        attr_writer(
          :_choices_,
          :_listener,
          :load_tests_by,
        )

        def RECEIVE_RUNTIME__ rt

          # unlike under onefile CLI, with an API call you have to
          # do the extra work of loading the files..

          svc = rt.__dereference_quickie_service_

          svc.__begin_irreversible_one_time_compound_mode_

          _x = @load_tests_by[ rt ]  # all 3 major players are accessible by runtime

          # (to have the above result be meaningful would be really annoying near tests..)

          _stats = svc.__end_irreversible_one_time_compound_mode_
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
          @_listener.call :data, :example do
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

    if false
    class Sessions_::Execute

      def initialize y, test_file_path_a, pn_s_a
        @ctx_class_a = []
        @ok = true
        @_pn_s_a = pn_s_a
        @tag_shell = nil
        @tag_filter_p = MONADIC_TRUTH_
        @test_file_path_a = test_file_path_a
        @be_verbose = nil
        @y = y
        block_given? and yield self
      end

      attr_accessor :be_verbose

      def with_iambic_phrase x_a
        @x_a = x_a
        send :"#{ x_a.fetch 0 }="
        @x_a = nil
        self
      end

      def produce_bound_call
        ok = @ok
        ok &&= load_test_files
        ok &&= resolve_client
        ok && via_client_produce_bound_call
      end

      def receive_test_context_class___ ctx_class
        @ctx_class_a << ctx_class
        nil
      end

    private

      def tag=

        ts = tag_shell

        1.upto( @x_a.length - 1 ).each do |d|
          ts.receive_tag_argument @x_a.fetch d
        end

        NIL_
      end

      def tag_shell
        @tag_shell ||= bld_tag_shell
      end

      def bld_tag_shell
        @excluded_count = 0
        wt_p_a = bk_p_a = nil
        @tag_filter_p = -> tagset do
          do_allow = true
          if bk_p_a
            bk_p_a.each do |p|
              _ok = p[ tagset ]
              if ! _ok
                do_allow = false
                break
              end
            end
          end
          if wt_p_a && do_allow
            do_allow = false
            wt_p_a.each do |p|
              _ok = p[ tagset ]
              if _ok
                do_allow = true
                break
              end
            end
          end
          if ! do_allow
            @excluded_count += 1
          end
          do_allow
        end

        Tags_Receiver_.new(

          :on_error, -> x do
            @ok = false
            @y << "#{ x }" ; nil
          end,

          :on_pass_filter_proc, -> p do
            ( wt_p_a ||= [] ).push p ; nil
          end,

          :on_no_pass_filter_proc, -> p do
            ( bk_p_a ||= [] ).push p ; nil
          end,

          :on_info_qualified_knownness, method( :report_tag ),
        )
      end

      def report_tag i, i_, x
        send :"report_#{ i }_tag", i_, x ; nil
      end

      def report_include_tag i, x
        @did_report_include_tag_once ||= begin
          @y << "(iff included then the test is run)" ; nil
        end
        @y << "(if not excluded and #{ i }:#{ x } then the test is included)" ; nil
      end

      def report_exclude_tag i, x
        @y << "(if #{ i }:#{ x } then the test is excluded)" ; nil
      end

      def load_test_files
        if ! (( a = @test_file_path_a )) then a else
          a.each do |path_s|
            @y << "(loading : #{ path_s })" if @be_verbose
            load path_s  # these attach context classes to the hookback above
          end
          true
        end
      end

      def resolve_client
        @client = build_client
        if @tag_shell
          @client.at_end_of_run do
            if @excluded_count.nonzero?
              @y << "(#{ @excluded_count } tests were excluded because tags)"
            end
          end
        end
        true
      end

      def via_client_produce_bound_call
        Common_::BoundCall[ nil, @client, :execute_ ]
      end

      def build_client

        a = @ctx_class_a ; @ctx_class_a = nil

        cli = Run_.new @y, :no_root_context, @_pn_s_a

        cli.filter_by_tags_by__( & @tag_filter_p )

        cli.produce_examples_by__ do | branch, leaf |
          p = nil
          pp = -> do
            if p
              true
            elsif a.length.nonzero?
              p = Build_example_stream_proc_[ a.shift, branch, leaf ]
              true
            end
          end
          none = get_saw_none_p
          -> do
            res = catch :res do
              while true
                pp[] or throw :res
                r = p[] and throw :res, r
                p = nil
              end
            end
            none[ res ]
          end
        end
        cli
      end

      def get_saw_none_p
        saw_none = true
        -> res do
          if saw_none
            if res
              saw_none = false
            else
              @y << "(no examples found by recursive runner)"
            end
          end
          res
        end
      end
    end
    end  # if false

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
      # ==
    end  # API
  end
end
# #history: began to splice brand new API client into legacy file
