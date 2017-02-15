module Skylab::TMX

  class CLI

    # primarily "tmx" (the CLI client) is for the high-level test-runner
    # ("test-all"). a need for high availability is one reason we have
    # rolled our own client rather than using a framework. as a side-
    # effect this is the frontier of argument-scanner-based clients.

    # secondarily (but in what used to be the primary function) this client
    # tries to "expose" through "mounting" participating installed
    # sidesystems, and also the one-off executables from ours and other `bin/`

    Invocation___ = self

    class Invocation___

      def initialize argv, sin, sout, serr, pn_s_a

        Require_interface_lib___[]

        @_do_dispatch_help = false
        @_data_emission_handler_method_via_terminal_channel_symbol = nil
        @listener = method :__receive_emission
        @args = __argument_scanner_via_argv_and_listener argv
        @__presumably_real_ARGV = argv
        @selection_stack = [ __build_root_frame ]
        @verbose_count_ = 0

        @stdin = sin
        @stdout = sout
        @stderr = serr
        @program_name_string_array = pn_s_a
      end

      def __argument_scanner_via_argv_and_listener argv
        Interface__::CLI_ArgumentScanner.define do |o|
          o.ARGV = argv
          o.listener = @listener
        end
      end

      def __build_root_frame
        RootFrame___.define do |rf|
          rf.didactics_by = -> do
            CLI::Magnetics_::HelpScreenDidactics_via_TMX_HostClient[ self ]
          end
          rf.argument_scanner = @args
        end
      end

      def json_file_stream_by & p
        @__json_file_stream_by = p
      end

      def json_file_stream_by__  # NOTE EXPERIMENT
        @__json_file_stream_by
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

      def to_bound_call
        # (for now we're doing it this way but if we wanted to we could
        #  probably make it work the weird way, like stop at 3 levels or etc)
        Common_::BoundCall.by do
          @stderr.puts "haha no (we could but why?)" ; NOTHING_
        end
      end

      def execute
        bc = __bound_call
        if bc
          x = bc.receiver.send bc.method_name, * bc.args, & bc.block
          if x
            send ( remove_instance_variable :@_express ), x
            @exitstatus ||= SUCCESS_EXITSTATUS__
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

        @omni = Interface__::ParseArguments_via_FeaturesInjections.define do |fi|
          __inject_features fi
        end
        if @args.no_unparsed_exists
          _when_no_arguments
        elsif _scan_operator_symbol_softly
          lu = @omni.flush_to_lookup_operator
          lu and __bound_call_via_found_operator lu
        elsif _scan_primary_symbol_softly
          __when_primary_at_head
        else
          _fail_about_unknown_primary_or_operator
        end
      end

      def __when_primary_at_head
        # help probably
        ok = @omni.flush_to_lookup_current_and_parse_remaining_primaries
        if ok
          if @verbose_count_.nonzero?
            @stderr.puts "(-verbose is for -help)"
          end
          _when_no_arguments  # assume parsed -v but no -h
        elsif @_do_dispatch_help
          # assume nonempty argument scanner
          if _scan_operator_symbol_softly
            lu = @omni.flush_to_lookup_operator
            lu and __bound_call_via_found_operator_when_dispatch_help lu
          else
            _fail_about_unknown_primary_or_operator
          end
        else
          ok  # assume EARLY_END from help
        end
      end

      def _fail_about_unknown_primary_or_operator
        @args.when_malformed_primary_or_operator
      end

      def _when_no_arguments
        Zerk_lib_[]::ArgumentScanner::When::No_arguments[ @omni ]
      end

      def __inject_features fi

        fi.argument_scanner = @args

        fi.add_hash_based_operators_injection OPERATORS___, :tmx_intrinsic

        fi.add_lazy_operators_injection_by do |o|
          __add_sidesystem_mounter_lazily o
        end

        fi.add_lazy_operators_injection_by do |o|
          __add_one_off_mounter_lazily o
        end

        fi.add_primaries_injection PRIMARIES___, self
      end

      def __add_sidesystem_mounter_lazily inj

        _inst = _installation

        ssm = CLI::Magnetics_::OperatorBranch_via_InstalledSidesystems.define do |o|
          o.CLI = self
          o.installation = _inst
        end

        inj.operators = ssm
        inj.injector = :tmx_mountable_sidesystem
        @__sidesys_mounter = ssm ; nil
      end

      def __add_one_off_mounter_lazily inj

        _inst = _installation

        ob = Zerk_lib_[]::Magnetics::OperatorBranch_via_Directory.call_by do |o|
          o.sidesystem_module = Home_
          o.glob_entry = "#{ _inst.participating_exe_prefix }*"
          o.filesystem_for_globbing = __filesystem_for_globbing
        end

        inj.operators = ob
        inj.injector = :tmx_mountable_one_off
        @__one_off_mounter = ob ; nil
      end

      def _installation  # #testpoint
        Home_.installation_
      end

      def __bound_call_via_found_operator_when_dispatch_help lu
        _to_operator_adapter_for( lu ).to_bound_call_for_help
      end

      def __bound_call_via_found_operator lu
        _to_operator_adapter_for( lu ).to_bound_call_for_invocation
      end

      def _to_operator_adapter_for lu
        case lu.injector
        when :tmx_intrinsic
          OperatorAdapter_for_Intrinsic___.new lu, self
        when :tmx_mountable_sidesystem
          OperatorAdapter_for_MountableSidesystem___.new lu, self
        when :tmx_mountable_one_off
          @_express = :__receive_exitstatus_of_one_off
          lu.mixed_business_value.TO_OPERATOR_ADAPTER_FOR self
        end
      end

      def _scan_operator_symbol_softly
        @args.scan_operator_symbol_softly
      end

      def _scan_primary_symbol_softly
        @args.scan_primary_symbol_softly
      end

      OPERATOR_DESCRIPTIONS = {
        test_all: :__describe_test_all,
        reports: :__describe_reports,
        map: :__describe_map,
        ping: :__describe_ping,
      }

      OPERATORS___ = {
        # (currently the below order determines help screen order)
        test_all: :__bound_call_for_test_all,
        reports: :__bound_call_for_reports,
        map: :__bound_call_for_map,
        ping: :__bound_call_for_ping,
      }

      PRIMARY_DESCRIPTIONS = {
        help: :__describe_help,
        verbose: :__describe_verbose,
      }

      PRIMARIES___ = {
        help: :_express_help,
        verbose: :_process_verbose,
      }

      # -- test all

      def __describe_test_all y
        y << "[ts] \"slowie\"'s high-level test running and reporting operations"
        y << "with some trivial adaptations (e.g verbosity)"
      end

      def __bound_call_for_test_all

        @_do_lipstick = false

        @_express = :__express_for_test_all

        @_table_schema = nil  # gets set by an emission if relevant

        _custom_listener = -> * chan, & p do
          # experimentally this feature was simplified out of the remote lib
          if :find_command_args == chan.last
            send @_on_find_command_do_this, p, chan
          else
            @listener[ * chan, & p ]
          end
        end

        @_on_find_command_do_this = :_no_op

        arg_scn = _multimode_argument_scanner_by do |o|

          o.user_scanner _user_scanner

          o.add_primary :help, method( :_express_help ), Describe_help__  # #coverpoint-1-C OPEN

          o.emit_into _custom_listener
        end

        arg_scn.on_first_branch_item_not_found do
          arg_scn.insert_at_head :require_only, :but_actually_run
          NIL
        end

        _lib = Home_.lib_.test_support::Slowie

        api = _lib::API.invocation_via_argument_scanner arg_scn do |o|

          _ = remove_instance_variable :@__test_file_name_pattern_by

          o.test_file_name_pattern_by( & _ )
        end

        # (perhaps the only time we need to "hand write" a push is when
        #  we "mount" another service. (just for help screens)):

        _push_frame do |fr|

          fr.name_symbol = :test_all
          fr.argument_scanner = arg_scn

          fr.define_didactics_by do |dida|
            Zerk_::Models::Didactics.define_conventionaly dida, api
          end
        end

        bc = api.to_bound_call_of_operator
        if bc
          if bc.receiver.respond_to? :test_directory_collection

            CLI::Magnetics_::BoundCall_via_TestDirectoryOrientedOperation.new(
              bc, @selection_stack.last.argument_scanner, self ).execute
          else
            bc
          end
        end
      end

      def receive_notification_that_you_should_express_find_commands
        @_on_find_command_do_this = :__express_current_find_command
        ACHIEVED_
      end

      def receive_notification_that_you_should_add_lipstick_column
        @_do_lipstick = true ; ACHIEVED_
      end

      # ~ emissions

      def __express_current_find_command p, chan
        self._REVIEW__changed_recently__be_sure_it_doesnt_inf_loop
        @listener[ * chan, & p ]
        NIL
      end

      def __express_for_test_all x

        if @_table_schema
          __attempt_to_render_a_table_in_a_general_way x
        elsif x.respond_to? :id2name
          @stdout.puts x.to_s  # for `ping`
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

        o.to_bound_call_of_operator
      end

      def __argument_scanner_for_reports  # see [#ze-052]

        _multimode_argument_scanner_by do |o|

          o.front_scanner_tokens :reports

          o.subtract_primary :json_file_stream_by, release_json_file_stream_by_

          o.default_primary :execute

          o.user_scanner _user_scanner

          o.add_primary :help, method( :_express_help ), Describe_help__  # #coverpoint-1-A OPEN

          o.emit_into @listener
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

        o.to_bound_call_of_operator
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

          o.user_scanner _user_scanner

          o.emit_into @listener
        end

        Add_slice_primary_[ 0, as, self ]

        as
      end

      # -- ping

      def __bound_call_for_ping
        Common_::BoundCall[ nil, self, :__do_ping ]
      end

      def __describe_ping y
        y << "(a minimal operation to test wiring)"
      end

      def __do_ping
        @listener.call :info, :expression, :ping do |y|
          y << "hello from tmx"
        end
        NOTHING_
      end

      # -- support for customizing emissions

      def on_this_do_this k, & p  # k = terminal_channel_symbol

        @_data_emission_handler_method_via_terminal_channel_symbol ||= {}
        @_data_emission_handler_method_via_terminal_channel_symbol[ k ] = :__on_this_do_this
        ( @__on_this_do_this ||= {} )[ k ] = p

        NIL
      end

      def __on_this_do_this

        _k = @_current_emission_expression.channel.last
        _p = @__on_this_do_this.fetch _k
        _p[ remove_instance_variable( :@_current_emission_expression ) ]  # ..
        NIL
      end

      def do_dispatch_help_= x
        @_do_dispatch_help = x
      end

      # -- support for expressing results (our version of [#ze-025])

      def __describe_help y
        y << "(this screen.)"
      end

      def _express_help
        CLI::When_::Help[ self ]
      end

      def __describe_verbose y
        y << "includes \"mountable sidesystems\" in the help listing"
      end

      def _process_verbose
        max = MAX_NUMBER_OF_VERBOSES___
        if max == @verbose_count_
          @stderr.puts "maximum verbosity level: #{ max }. reduce the number & try again"
          _failed
        else
          @verbose_count_ += 1 ; ACHIEVED_
        end
      end

      # ~ (near) boilerplate for help

      def describe_into y
        y << "experiment.."
      end

      def argument_scanner  # because we are top, we don't alter our stream
        self._CONTACT_CHECK
        NOTHING_
      end

      # --

      def __attempt_to_render_a_table_in_a_general_way row_st

        # experimental - make a table design from the emitted table
        # schema, including "max share meters"

        _design = Zerk_::CLI::Table::Design.define do |defn|

          defn.separator_glyphs NOTHING_, SPACE_ * 2 , NOTHING_

          _ts = remove_instance_variable :@_table_schema
          _bx = _ts.field_box
          _bx.to_enum( :each_value ).each_with_index do |fld, input_offset|

            label = UC_first___[ fld.name.as_human ]

            if fld.is_numeric

              defn.add_field :right, :label, label

              if @_do_lipstick

                Zerk_::CLI::HorizontalMeter.
                    add_max_share_meter_field_to_table_design defn do |o|

                  o.for_input_at_offset input_offset
                  o.foreground_glyph '*'
                  o.background_glyph DASH_
                end
              end
            else
              defn.add_field :right, :label, label
            end

            _width = Home_.lib_.brazen::CLI.some_screen_width

            defn.target_final_width _width
          end
        end

        st = _design.line_stream_via_mixed_tuple_stream row_st

        while line = st.gets
          @stdout.puts line
        end

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
        else
          @stderr.puts "(no results.)"  # #not-covered
        end
        NIL
      end

      def __expresser_for_string_or_name x
        sout = @stdout
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

      def _user_scanner
        d, a = @args.close_and_release
        if @_do_dispatch_help  # :#here-1
          HELP_RX =~ a.first || self._SANITY
          d == 2 || self._HMM
          a[0] = a[1]  # probably not useful
          a[1] = '-help'  # like HELP_SWITCH_LONG_ but assert our way
          d -= 1
        end
        Common_::Scanner.via_start_index_and_array d, a
      end

      # --

      def __receive_emission * chan, & em_p

        _HORRIBLE = -> do

          # this is #open [#007.A] (related) until we make maximal expags
          # subclass minimal expags, we have to guess at which is right.
          # if such a time comes, we could just only ever use maximal.
          # or keep this craziness, but this just ain't right

          if 1 == @selection_stack.length
            __expression_agent_for_minimal
          else
            __expression_agent_for_maximal
          end
        end

        expr = Interface__::CLI_Express_via_Emission.define do |o|

          o.expression_agent_by = -> do
            _HORRIBLE[]
          end

          o.emission_proc_and_channel em_p, chan
          o.client = self
            # emissions of `emission_handler_methods`, `data`
        end

        @_current_emission_expression = expr

        sct = expr.execute
        if sct && sct.was_error
          __when_result_was_error chan
        end

        NIL
      end

      def __when_result_was_error chan

        case chan[2]
        when :parse_error
          _invite_to_general_help

        when :primary_parse_error
          # :#coverpoint-1-F: for now, on a primary parse error, we invite
          # to a help IFF it presumably belongs to the root. in future etc.
          if 1 == @selection_stack.length
            _invite_to_general_help  # #coverpoint-1-F
          end
        end

        _failed ; nil
      end

      def invite_to_general_help_and_failed
        _invite_to_general_help
        _failed
      end

      def __expression_agent_for_maximal
        Zerk_lib_[]::NonInteractiveCLI::ArgumentScannerExpressionAgent.instance
      end

      def __expression_agent_for_minimal
        Interface__::CLI_InterfaceExpressionAgent.instance
      end

      def _invite_to_general_help
        @stderr.puts "try '#{ get_program_name } -h'"
        NIL
      end

      def get_program_name
        ::File.basename @program_name_string_array.last
      end

      def _failed
        @exitstatus ||= FAILURE_EXITSTATUS__  # EEK
        UNABLE_
      end

      def __receive_exitstatus_of_one_off d
        d.respond_to? :bit_length || self._NON_COMPLIANT_ONE_OFF_EXECUTABLE
        @exitstatus = d
        NIL
      end

      def _no_op(*)
        NOTHING_
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # -- for magentics & other collaborators (e.g emission expresser)

      # ~ for "mounting"

      def filesystem_proc  # [ts]
        _always_needed = Home_.lib_.system.filesystem
        -> { _always_needed }
      end

      def __filesystem_for_globbing  # #testpoint
        ::Dir
      end

      # ~

      def receive_data_emission data_p, channel

        h = @_data_emission_handler_method_via_terminal_channel_symbol
        if h
          m = h[ channel.fetch( -1 ) ]
        end
        if m
          send m, & data_p
        else
          send RECEIVE_DATA___.fetch( channel.fetch(1) ), & data_p
        end
      end

      RECEIVE_DATA___ = {
        operator_resolved: :_push_frame,
        table_schema: :__receive_table_schema,
      }

      def _push_frame  # exactly [#ze-055] #note-1, #note-2

        _frame = NonRootFrame___.define do |fr|
          fr.below_didactics_by = @selection_stack.last.didactics_by
          yield fr
        end

        @selection_stack.push _frame
        NIL
      end

      def __receive_table_schema
        @_table_schema = yield
        NIL
      end

      def line_yielder_for_info
        @___line_yielder_for_info ||= Build_info_yielder___[ @stderr ]
      end

      def rewrite_ARGV * s_a

        # 2x tagged by :#spot-3 we hackishly rewrite the *REAL* `ARGV`
        # (the global array) to pass parameters into rspec EEW

        real = remove_instance_variable :@__presumably_real_ARGV

        scn = remove_instance_variable :@args
        if ! scn.is_closed
          _, a = scn.close_and_release__
          a.object_id == real.object_id || self._SANITY
        end

        real.replace s_a
        NIL
      end

      def release_argument_scanner_for_mounted_operator  # 1x here 1x [ze]

        # (when having succeeded in mounting a participating sidesystem,
        #  (and now one-off),
        #  we want to make it clear that we ourselves are totally done
        #  parsing (or otherwise referencing) arguments)

        remove_instance_variable :@args
      end

      attr_writer(
        :exitstatus,
      )

      attr_reader(
        :args,
        :listener,
        :omni,
        :program_name_string_array,
        :selection_stack,
        :stderr,
        :stdin,
        :stdout,
        :verbose_count_,
      )
    end

    # ==

    Add_slice_primary_ = -> d, as, cli do

      _at_slice = -> do

        sct = CLI::Magnetics_::ParsedStructure_via_ArgumentStream_for_Paging.
          new( cli ).execute

        if sct

          # (this is [#016] a place where we add tokens back into the scanner
          # after it became empty. (remote lib must cover this.)

          as.insert_at_head(
            :page_by, :item_count,
            :page_size_denominator, sct.denominator,
            :page_offset, sct.ordinal_offset,
          )
          ACHIEVED_
        else
          NIL  # nil not false, #coverpoint-1-C
        end
      end

      as.add_primary_at_position d, :slice, _at_slice, Describe_slice___
      NIL
    end

    Describe_slice___ = -> y do
      y << "experimental \"fun\" version of -page-by."
      y << "(\"-help\" as its first argument shows modifier-specific help)"
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

    class OperatorAdapter_for_Intrinsic___

      def initialize lu, cli
        @lookup = lu
        @CLI = cli
      end

      def to_bound_call_for_help
        # (the work is done #here-1)
        @CLI.do_dispatch_help_ = true
        to_bound_call_for_invocation
      end

      def to_bound_call_for_invocation
        @CLI.send @lookup.mixed_business_value
      end
    end

    class OperatorAdapter_for_MountableSidesystem___

      def initialize lu, cli
        @lookup = lu
        @sidesystem_mounter = cli.remove_instance_variable :@__sidesys_mounter
      end

      def to_bound_call_for_help
        @sidesystem_mounter.bound_call_for_help_via_load_ticket__ _LT
      end

      def to_bound_call_for_invocation
        @sidesystem_mounter.bound_call_for_invocation_via_load_ticket__ _LT
      end

      def _LT
        @lookup.mixed_business_value
      end
    end

    # ==

    class NonRootFrame___ < SimpleModel_

      def initialize
        yield self
        # can't freeze b.s name vs name_symbol
      end

      def define_didactics_by & p
        @__define_didactics = p
      end

      attr_writer(
        :argument_scanner,  # @__argument_scanner
        :below_didactics_by,
        :name,  # k
        :name_symbol,  # :@__name_symbol
        :operator_instance,  # @__operator_instance
      )

      def didactics_by
        method :to_didactics
      end

      def to_didactics
        Zerk_::Models::Didactics.define do |o|
          @__define_didactics[ o ]
          o.name = name
          o.below_didactics_by = @below_didactics_by
        end
      end

      def name_symbol
        @name_symbol ||= name.as_variegated_symbol  # risk of inf. loop
      end

      def name
        @name ||= __if_name_wasnt_set_then_name_symbol_must_have_been_set
      end

      def __if_name_wasnt_set_then_name_symbol_must_have_been_set
        Common_::Name.via_variegated_symbol @name_symbol
      end

      def operator_instance__  # special needs only
        @operator_instance
      end

      attr_reader(
        :argument_scanner,
      )
    end

    class RootFrame___ < SimpleModel_

      attr_accessor(
        :argument_scanner,
        :didactics_by,
      )

      def to_didactics
        @didactics_by.call
      end
    end

    # ==

    Require_interface_lib___ = Lazy_.call do
      require 'no-dependencies-zerk'
      Interface__ = ::NoDependenciesZerk
      NIL
    end

    # ==

    FAILURE_EXITSTATUS__ = 5
    HELP_RX = /\A-{0,2}h(?:e(?:lp?)?)?\z/
    MAX_NUMBER_OF_VERBOSES___ = 2
    SUCCESS_EXITSTATUS__ = 0

    # ==
  end  # end new CLI class
end
# #tombstone: orphan test-all executable binary (meta-tombtone: orig GREENLIST)
