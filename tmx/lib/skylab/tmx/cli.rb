module Skylab::TMX

  class CLI

    # primarily "tmx" (the CLI client) is for the high-level test-runner
    # ("test-all"). a need for high availability is one reason we have
    # rolled our own client rather than using a framework. as a side-
    # effect this is the frontier of argument-scanner-based clients.

    # secondarily (but in what used to be the primary function) this client
    # tries to "mount" and "expose" other participating related sidesystems.

    Invocation___ = self

    class Invocation___

      def initialize argv, i, o, e, pn_s_a

        @argv = Common_::Polymorphic_Stream.via_array argv

        @selection_stack = [ RootFrame___.new do
          Zerk_lib_[]::Models::Didactics.via_participating_operator__ self
        end ]

        @_end_of_stream = :_no_op
        @sin = i
        @serr = e
        @sout = o
        @program_name_string_array = pn_s_a
      end

      def json_file_stream_by & p
        @__json_file_stream_by = p
      end

      def metadata_filename_by & p
        @__metadata_filename_by = p
      end

      def test_directory_entry_name_by & p
        @__test_directory_entry_name_by = p
      end

      def test_file_name_pattern_by & p
        @__test_file_name_pattern_by = p
      end

      def execute

        bc = __bound_call
        if bc
          x = bc.receiver.send bc.method_name, * bc.args, & bc.block
          if x
            @exitstatus ||= SUCCESS_EXITSTATUS__
            send ( remove_instance_variable :@_express ), x
          elsif x.nil?
            @exitstatus ||= SUCCESS_EXITSTATUS__
          end
        elsif bc.nil?
          @exitstatus ||= SUCCESS_EXITSTATUS__
        end
        @exitstatus
      end

      # --

      def __bound_call

        if @argv.no_unparsed_exists
          __when_no_args

        elsif Looks_like_option[ @argv.current_token ]
          __when_head_looks_like_option

        elsif __head_is_intrinsic_operator
          __bound_call_for_intrinsic_operator

        elsif __head_is_mountable_operator
          __bound_call_for_mountable_operator

        else
          __whine_about_no_such_operator
        end
      end

      def __whine_about_no_such_operator
        @serr.puts "DOOTILY MY FOOTILY #{ @argv.current_token.inspect }"
        invite_to_general_help
      end

      def __when_no_args

        self._PROBABLY_CHANGE_THIS_TO_BE_MORE_INCLUSIVE

        _init_selective_listener

        @listener.call :error, :expression, :parse_error do |y|

          _st = Stream_.call OPERATIONS__.keys do |sym|
            Common_::Name.via_variegated_symbol sym
          end

          _any_of_these = say_formal_operation_alternation _st

          y << "expecting #{ _any_of_these }"
        end

        UNABLE_
      end

      def __when_head_looks_like_option  # assume 0 < argv length
        if HELP_RX =~ @_current_token
          _express_help
        else
          __when_unrecognized_option_at_front
        end
      end

      def __when_unrecognized_option_at_front
        @serr.puts "unrecognized option: #{ @argv.current_token.inspect }"
        invite_to_general_help
      end

      def __head_is_intrinsic_operator

        entry = @argv.current_token.gsub DASH_, UNDERSCORE_

        if _store :@__operation_method_name, OPERATIONS__[ entry.intern ]
          ACHIEVED_
        else
          @__possible_entry = entry
          UNABLE_
        end
      end

      def __bound_call_for_intrinsic_operator
        @argv.advance_one
        _init_selective_listener
        send remove_instance_variable :@__operation_method_name
      end

      OPERATION_DESCRIPTIONS___ = {
        test_all: :__describe_test_all,
        reports: :__describe_reports,
        map: :__describe_map,
      }

      OPERATIONS__ = {
        # (currently the below order determines help screen order)
        test_all: :__bound_call_for_test_all,
        reports: :__bound_call_for_reports,
        map: :__bound_call_for_map,
      }

      # -- test all

      def __describe_test_all y
        y << "[ts] \"slowie\"'s high-level test running and reporting operations"
        y << "with some trivial adaptations (e.g verbosity)"
      end

      def __bound_call_for_test_all

        @_do_lipstick = false

        @_express = :__express_for_test_all

        @_emission_handler_methods_ = {
          # (special handling of emissions by terminal channel name symbol)
          find_command_args: :_no_op,
        }

        @_table_schema = nil  # gets set by an emission if relevant

        arg_scn = _multimode_argument_scanner_by do |o|

          o.user_scanner remove_instance_variable :@argv

          o.add_primary :help, method( :_express_help ), Describe_help__  # #coverpoint-1-C OPEN

          o.listener @listener
        end

        arg_scn.on_first_branch_item_not_found do
          arg_scn.insert_at_head :require_only, :but_actually_run
          NIL
        end

        _lib = Home_.lib_.test_support::Slowie

        api = _lib::API.begin_invocation_by arg_scn do |o|

          _ = remove_instance_variable :@__test_file_name_pattern_by

          o.test_file_name_pattern_by( & _ )
        end

        # (perhaps the only time we need to "hand write" a push is when
        #  we "mount" another service. (just for help screens)):

        _push_frame do |y|

          y.yield :name_symbol, :test_all
          y.yield :argument_scanner, arg_scn

          y.yield :define_didactics_by, -> dida_y do
            Zerk_::Models::Didactics.define_conventionaly dida_y, api
          end
        end

        bc = api.to_bound_call_of_operator
        if bc
          if bc.receiver.respond_to? :test_directory_collection

            CLI::Magnetics_::BoundCall_via_TestDirectoryOrientedOperation.new(
              bc, @selection_stack.last.argument_scanner, self ).execute  # :#here
          else
            bc
          end
        end
      end

      def receive_notification_that_you_should_express_find_commands
        @_emission_handler_methods_[ :find_command_args ] = :__express_current_find_command
        ACHIEVED_
      end

      def receive_notification_that_you_should_add_lipstick_column
        @_do_lipstick = true ; ACHIEVED_
      end

      # ~ emissions

      def __express_current_find_command
        @_current_emission_expression._express_normally_
        NIL
      end

      def __express_for_test_all x

        if @_table_schema
          __attempt_to_render_a_table_in_a_general_way x
        elsif x.respond_to? :id2name
          @sout.puts x.to_s  # for `ping`
        else
          _express_stream_of_string_or_name x
        end
        NIL
      end

      # -- reports

      def __describe_reports y
        y << "currently just one, to generate the \"punchlist\""
      end

      def __bound_call_for_reports

        @_express = :_express_stream_of_string_or_name

        o = Home_::API.begin( & @listener )

        o.argument_scanner = __argument_scanner_for_reports

        _bound_call_via_API_invocation o
      end

      def __argument_scanner_for_reports  # see [#ze-052]

        _multimode_argument_scanner_by do |o|

          o.front_scanner_tokens :reports

          o.subtract_primary :json_file_stream_by, release_json_file_stream_by_

          o.default_primary :execute

          o.user_scanner remove_instance_variable :@argv

          o.add_primary :help, method( :_express_help ), Describe_help__  # #coverpoint-1-A OPEN

          o.listener @listener
        end
      end

      # -- map

      def __describe_map y
        y << "given a query, produce a stream of nodes."
        y << "(the underlying mechanics of most of the other operations)"
      end

      def __bound_call_for_map

        @_express = :__express_stream_of_map_nodes

        o = Home_::API.begin( & @listener )

        o.argument_scanner = __argument_scanner_for_map

        _bound_call_via_API_invocation o
      end

      def __express_stream_of_map_nodes st
        _express_non_empty_stream :__express_map_item, st
      end

      def __express_map_item x

        x.respond_to? :get_filesystem_directory_entry_string || _NO

        o = CLI::Magnetics_::
          MapItemExpresser_via_Client_and_FirstItem_and_Options.begin(
            self, x )

        # ..

        o.execute
      end

      def __argument_scanner_for_map  # see [#ze-052]

        as = _multimode_argument_scanner_by do |o|

          o.front_scanner_tokens :map  # invoke this operation when calling API

          o.subtract_primary :json_file_stream_by, release_json_file_stream_by_

          o.subtract_primary :json_file_stream  # used in testing, never in UI

          o.subtract_primary :attributes_module_by, -> { Home_::Attributes_ }

          o.subtract_primary :result_in_tree  # for now

          o.add_primary :help, method( :_express_help ), Describe_help__  # #coverpoint-1-B OPEN

          o.user_scanner remove_instance_variable :@argv

          o.listener @listener
        end

        Add_slice_primary_[ 0, as, self ]

        as
      end

      # -- generic mounting

      # when the front element of the ARGV directly corresponds to a
      # sidesystem (gem), then resolution of the intended recipient is much
      # more straightforward than having to load possibly the whole tree.

      def __head_is_mountable_operator

        mounter = CLI::Magnetics_::BoundCall_via_MountAnyInstalledSidesystem.new(
          remove_instance_variable( :@__possible_entry ),
          self,
          Home_.installation_,
        )

        # (we could extend this "optimization" to the executables but meh)

        if mounter.match_head_as_participating_gem
          @__mounter = mounter ; ACHIEVED_
        end
      end

      def __bound_call_for_mountable_operator
        remove_instance_variable( :@__mounter ).bound_call_for_participating_sidesystem
      end

      # -- support for customizing emissions

      def on_this_do_this k, & p  # k = terminal_channel_symbol

        @_emission_handler_methods_[ k ] = :__on_this_do_this
        ( @__on_this_do_this ||= {} )[ k ] = p

        NIL
      end

      def __on_this_do_this

        _k = @_current_emission_expression.channel_symbol_array.last
        _p = @__on_this_do_this.fetch _k
        _p[ remove_instance_variable( :@_current_emission_expression ) ]  # ..
        NIL
      end

      # -- support for expressing results (our version of [#ze-025])

      def _express_help

        top = @selection_stack.last
        di = top.to_didactics  # buckle up

        # -- derive things from the didactics

        _help_screen_mod = CLI_support_[]::When::Help.const_get(
          di.is_branchy ? :ScreenForBranch : :ScreenForEndpoint, false )

        desc_reader = di.description_proc_reader

        items = di.item_normal_tuple_stream_by[]

        # -- maybe alter things by the argument scanner

        if 1 != @selection_stack.length
          as = top.argument_scanner
          desc_reader = as.altered_description_proc_reader_via desc_reader
          items = as.altered_normal_tuple_stream_via items
        end

        # --

        _help_screen_mod.express_into @serr do |o|

          o.item_normal_tuple_stream items

          o.express_usage_section Program_name_via_client___[ self ]

          o.express_description_section di.description_proc

          o.express_items_sections desc_reader
        end

        @exitstatus = SUCCESS_EXITSTATUS__

        NOTHING_  # stop parsing without failing
      end

      # ~ (near) boilerplate for help

      def is_branchy
        true
      end

      def describe_into y
        y << "experiment.."
      end

      def description_proc_reader
        -> sym do
          method OPERATION_DESCRIPTIONS___.fetch sym
        end
      end

      def to_item_normal_tuple_stream
        self._PROBABLY_CHANGE_THIS_TO_BE_MORE_INCLUSIVE
        Stream_.call OPERATIONS__.keys do |sym|
          [ :operator, sym ]
        end
      end

      def argument_scanner  # because we are top, we don't alter our stream
        NOTHING_
      end

      # --

      def __attempt_to_render_a_table_in_a_general_way row_st

        # just a sketch

        defn = []

        d = 0 ; yes = false

        _ts = remove_instance_variable :@_table_schema
        box = _ts.field_box
        box.each_value do |fld|

          if fld.is_numeric
            d += 1
            yes = true
          else
            yes = false
          end

          defn.push :field, :right, :label, UC_first___[ fld.name.as_human ]
        end

        if @_do_lipstick && 1 == d

          # for now we render "lipstick" only if and always if there is
          # exactly one numeric field, and it is last. later we will do it
          # over some --verbose threshold.

          # add a whole cel to each row dedicated to being rendered as lipstick:

          read_rows_from = row_st.map_by do |muta_a|
            muta_a.push muta_a.last
            muta_a
          end

          _width = Home_.lib_.brazen::CLI.some_screen_width

          defn.push(
            :target_width, _width,
            :field, :gather_statistics,
            :max_share_meter,
              :of_column, box.length,  # selfsame column
              :glyph, '*',
              :background_glyph, '-',
          )
        else
          read_rows_from = row_st
        end

        defn.push(
          :read_rows_from, read_rows_from,
          :write_lines_to, @sout,
        )
        CLI_support_[]::Table::Actor.call_via_arguments defn
        NIL
      end

      def _express_stream_of_string_or_name st
        _express_non_empty_stream :__expresser_for_string_or_name, st
      end

      def _express_non_empty_stream m, st
        x = st.gets
        if x
          express = send m, x
          begin
            express[ x ]
            x = st.gets
            x ? redo : break
          end while above
          send @_end_of_stream
        else
          @serr.puts "(no results.)"  # #not-covered
        end
        NIL
      end

      def __expresser_for_string_or_name x
        sout = @sout
        if x.respond_to? :ascii_only?
          -> line do
            sout.puts line  # hi.
          end
        elsif x.respond_to? :as_slug
          -> name do
            sout.puts name.as_slug
          end
        else
          _NO
        end
      end

      # -- preparing calls to the backend

      def _multimode_argument_scanner_by & defn
        Zerk_lib_[]::NonInteractiveCLI::MultiModeArgumentScanner.define( & defn )
      end

      def release_json_file_stream_by_
        remove_instance_variable :@__json_file_stream_by
      end

      def release_metadata_filename__
        remove_instance_variable( :@__metadata_filename_by ).call
      end

      def release_test_directory_entry_name_by__
        remove_instance_variable :@__test_directory_entry_name_by
      end

      def _bound_call_via_API_invocation o
        @API_invocation_ = o
        o.to_bound_call_of_operator
      end

      # --

      def _init_selective_listener

        expsr = nil  # only build it once an emission is received
        @listener = -> * sym_a, & em_p do
          expsr ||= HardcodedEmissionExpresserForNow___.new self
          ee = expsr.dup
          @_current_emission_expression = ee
          ee.invoke em_p, sym_a
        end
        NIL
      end

      def invite_to_general_help
        @serr.puts "try '#{ get_program_name } -h'"
        _failed
      end

      def get_program_name
        ::File.basename @program_name_string_array.last
      end

      def expression_agent
        Zerk_lib_[]::NonInteractiveCLI::ArgumentScannerExpressionAgent.instance
      end

      def _failed
        @exitstatus = FAILURE_EXITSTATUS__
        UNABLE_
      end

      def _no_op
        NOTHING_
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # -- for magentics & other collaborators (e.g emission expresser)

      # ~ for "mounting"

      def filesystem_proc  # [ts]
        _always_needed = Home_.lib_.system.filesystem
        -> { _always_needed }
      end

      # ~

      def receive_data_emission data_p, channel
        send RECEIVE_DATA___.fetch( channel.fetch(1) ), & data_p
      end

      RECEIVE_DATA___ = {
        operator_resolved: :_push_frame,
        table_schema: :__receive_table_schema,
      }

      def _push_frame  # exactly [#ze-008] #note-1, #note-2

        _frame = NonRootFrame___.new @selection_stack.last.didactics_by do |fr|
          yield( ::Enumerator::Yielder.new do |k, x|
            fr.receive x, k  # hi.
          end )
        end

        @selection_stack.push _frame
        NIL
      end

      def __receive_table_schema
        @_table_schema = yield
        NIL
      end

      def line_yielder_for_info
        @___line_yielder_for_info ||= Build_info_yielder___[ @serr ]
      end

      def rewrite_ARGV * s_a
        release_ARGV.array_for_read.replace s_a
        NIL
      end

      def release_ARGV
        remove_instance_variable :@argv
      end

      attr_writer(
        :exitstatus,
      )

      attr_reader(
        :API_invocation_,
        :listener,
        :_emission_handler_methods_,
        :program_name_string_array,
        :selection_stack,
        :serr,
        :sin,
        :sout,
      )
    end

    # ==
    if false
    def __to_unbound_stream

      _st = Home_.installation_.to_sidesystem_manifest_stream

      # sess.number_of_synopsis_lines = 2
      # sess.program_name_string_array = pn_s_a

      _st.expand_by do | manifest |

        manifest.to_unboundish_stream
      end
    end
    end

    # ==

    Add_slice_primary_ = -> d, as, cli do

      _at_slice = -> do

        sct = CLI::Magnetics_::ParsedStructure_via_ArgumentStream_for_Paging.
          new( cli ).execute

        if sct
          as.insert_at_head(
            :page_by, :item_count,
            :page_size_denominator, sct.denominator,
            :page_offset, sct.ordinal_offset,
          )
          ACHIEVED_
        else
          sct  # #cover-me (covered visually)
        end
      end

      as.add_primary_at_position d, :slice, _at_slice, Describe_slice___
      NIL
    end

    Describe_slice___ = -> y do
      y << "experimental \"fun\" version of -page-by."
      y << "(\"-help\" as its first argument shows modifier-specific help)"
    end

    # ==

    class HardcodedEmissionExpresserForNow___

      # this stays very close to its only client. is a separate class only
      # so that it can have a clean, dedicated ivar space per emission.
      #
      # (everything is built lazily because the variety of shapes of
      # emission we receive (event, expression, data) all use different
      # resources.)

      def initialize client
        @CLI = client
        @_info_yielder = client.method :line_yielder_for_info
        @__emission_handler_methods = client._emission_handler_methods_ || MONADIC_EMPTINESS_
      end

      def invoke em_p, sym_a
        @channel_symbol_array = sym_a
        @emission_proc = em_p
        m = @__emission_handler_methods[ @channel_symbol_array.last ]
        if m
          @CLI.send m  # no args - client should have an ivar holding self
        else
          _express_normally_
        end
      end

      def _express_normally_
        if :expression == @channel_symbol_array[1]
          __express_expression
        elsif :data == @channel_symbol_array[0]
          __send_data
        else
          __express_event
        end
        NIL
      end

      def __express_event
        _ev = @emission_proc.call
        _ev.express_into_under @_info_yielder[], @CLI.expression_agent
        _maybe_invite
        NIL
      end

      def __express_expression
        @CLI.expression_agent.calculate @_info_yielder[], & @emission_proc
        _maybe_invite
        NIL
      end

      def _maybe_invite
        if :parse_error == @channel_symbol_array[2]
          @CLI.invite_to_general_help  # ..
        elsif :error == @channel_symbol_array[0]
          @CLI.exitstatus = FAILURE_EXITSTATUS__
        end
        NIL
      end

      def __send_data
        @CLI.receive_data_emission @emission_proc, @channel_symbol_array
        NIL
      end

      attr_reader(
        :channel_symbol_array,
        :emission_proc,
      )
    end

    # ==

    name_stream_via_selection_stack = nil

    Program_name_via_client___ = -> client do

      buffer = client.get_program_name
      st = name_stream_via_selection_stack[ client.selection_stack ]
      begin
        nm = st.gets
        nm || break
        buffer << SPACE_ << nm.as_slug
        redo
      end while nil
      buffer
    end

    name_stream_via_selection_stack = -> ss do
      Common_::Stream.via_range( 1  ... ss.length ).map_by do |d|
        ss.fetch( d ).name
      end
    end

    Describe_help__ = -> y do
      y << "this screen."
    end

    Build_info_yielder___ = -> serr do
      ::Enumerator::Yielder.new do |s|
        serr.puts s  # hi.
      end
    end

    UC_first___ = -> s do
      "#{ s[0].upcase }#{ s[1..-1] }"
    end

    # ==

    Looks_like_option = -> do
      d = DASH_.getbyte 0  # DASH_BYTE_
      -> s do
        d == s.getbyte(0)
      end
    end.call

    # ==

    class NonRootFrame___

      def initialize above_dida_p
        @__above_didactics_by = above_dida_p
        yield self
      end

      def receive x, k
        instance_variable_set WRITABLE___.fetch( k ), x
      end

      WRITABLE___ = {
        argument_scanner: :@__argument_scanner,
        define_didactics_by: :@define_didactics_by,
        name: :@name,
        name_symbol: :@__name_symbol,
        operator_instance: :@__operator_instance,
      }

      def didactics_by
        method :to_didactics
      end

      def to_didactics
        Zerk_::Models::Didactics.non_rootly__ @define_didactics_by, name, @__above_didactics_by
      end

      def name_symbol
        @name_symbol ||= name.as_variegated_symbol  # risk of inf. loop
      end

      def name
        @name ||= __if_name_wasnt_set_then_name_symbol_must_have_been_set
      end

      def __if_name_wasnt_set_then_name_symbol_must_have_been_set
        Common_::Name.via_variegated_symbol(
          remove_instance_variable :@__name_symbol )
      end

      def argument_scanner
        @__argument_scanner
      end

      def operator_instance__  # special needs only
        @__operator_instance
      end
    end

    class RootFrame___

      def initialize & p
        @didactics_by = p
      end

      def to_didactics
        @didactics_by.call
      end

      attr_reader(
        :didactics_by,
      )
    end

    # ==

    CLI_support_ = Lazy_.call do
      Home_.lib_.brazen::CLI_Support
    end

    # ==

    FAILURE_EXITSTATUS__ = 5
    HELP_RX = /\A-{0,2}h(?:e(?:lp?)?)?\z/
    SUCCESS_EXITSTATUS__ = 0

    # ==
  end  # end new CLI class
end
# #tombstone: orphan test-all executable binary (meta-tombtone: orig GREENLIST)
