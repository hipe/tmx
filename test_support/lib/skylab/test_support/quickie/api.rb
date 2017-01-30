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
              o._choices = @__choices
              o._listener = @_listener
            end
          end
          ok && @_client
        end

        def __resolve_choices
          @_formal_primaries_cache = {}
          @_formal_primaries_hash = {}
          _ = Choices_via_AssignmentsProc_and_Client__.call self do |cx|
            @_writable_choices = cx.writable_choices
            cx.write_formal_primaries_into self
            remove_instance_variable :@_writable_choices
            __add_bespoke_primaries
            __parse_arguments
          end
          _store :@__choices, _
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

          until @_scanner.no_unparsed_exists
            __accept_one_primary
          end
          __check_requireds
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

        def __accept_one_primary
          fo = __gets_one_formal_primary
          send ROUTE___.fetch( fo.route ), fo
          NIL
        end

        ROUTE___ = {
          _this_is_an_API_specific_primary_: :__process_API_specific_primary,
        }

        def __process_API_specific_primary fo

          if fo.is_plural

            self._CODE_SKETCH__worked_previously__
            @_client.send( fo.plural_name_symbol ).push @_scanner.gets_one

          elsif fo.is_flag

            self._CODE_SKETCH__worked_previously__
            @_client.send :"#{ fo.name_symbol }=", true

          else
            curr_x = @_client.send fo.name_symbol
            _next_x = @_scanner.gets_one
            if curr_x.nil?
              @_client.send :"#{ fo.name_symbol }=", _next_x
            else
              self._COVER_ME__wont_clobber__or_will_I__
            end
          end
          NIL
        end

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
          :_choices,
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

      class API_Primary___ < Common_::SimpleModel

        def initialize
          @_argument_arity_mutex = nil
          yield self
          instance_variable_defined? :@_argument_arity_mutex and
            remove_instance_variable :@_argument_arity_mutex
          freeze
        end

        # -- write

        attr_writer(
          :name_symbol,
          :route,
        )

        def be_flag
          remove_instance_variable :@_argument_arity_mutex
          @is_flag = true ; nil
        end

        def be_plural
          remove_instance_variable :@_argument_arity_mutex
          @__plural_name_symbol = :"#{ @name_symbol.id2name }s"  # ..
          @_plural_name_symbol = :__plural_name_symbol
          @is_plural = true ; nil
        end

        # -- read

        def plural_name_symbol
          send @_plural_name_symbol
        end

        def __plural_name_symbol
          @__plural_name_symbol  # hi.
        end

        attr_reader(
          :is_flag,
          :is_plural,
          :name_symbol,
          :route,
        )
      end

      # ==

    end  # API
  end
end
# #history: began to splice brand new API client into legacy file
