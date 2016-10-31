module Skylab::TMX

  class CLI

    # at the moment all the the code here falls decisively into either the
    # "pre-map" or "post-map" era. "pre-map" is all commented out for now.
    # "post-map" is largely a frontier playground for exciting adaptation experiments.

    Invocation___ = self

    class Invocation___

      def initialize i, o, e, pn_s_a
        @_BE_VERBOSE = false  # ..
        @_end_of_stream = :_noop
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

      def invoke argv
        @argv = argv
        bc = __bound_call
        if bc
          x = bc.receiver.send bc.method_name, * bc.args, & bc.block
          if x
            @exitstatus ||= SUCCESS_EXITSTATUS__
            send ( remove_instance_variable :@_express ), x
          end
        end
        @exitstatus
      end

      # --

      def __bound_call

        if @argv.length.zero?
          __when_no_args
        elsif Looks_like_option[ @argv.first ]
          __when_looks_like_option_at_front
        else
          __when_looks_like_operation_at_front
        end
      end

      def __when_no_args

        st = _to_didactic_operation_name_stream

        _parse_error_listener.call :error, :expression, :parse_error do |y|

          _any_of_these = say_formal_operation_alternation st

          y << "expecting #{ _any_of_these }"
        end

        UNABLE_
      end

      def __when_looks_like_option_at_front  # assume 0 < argv length
        if HELP_RX =~ @argv.first
          __when_general_help
        else
          __when_unrecognized_option_at_front
        end
      end

      def __when_unrecognized_option_at_front
        @serr.puts "unrecognized option: #{ @argv.first.inspect }"
        invite_to_general_help
      end

      def __when_general_help

        CLI::HelpScreen::ForBranch.express_into @serr do |o|

          o.operation_description_hash OPERATION_DESCRIPTIONS__

          o.usage _program_name

          o.description_by do |y|
            y << "experiment.."
          end

          o.express_operation_descriptions_against self
        end
        @exitstatus = SUCCESS_EXITSTATUS__
        NIL
      end

      def __when_looks_like_operation_at_front

        scn = Common_::Polymorphic_Stream.via_array @argv

        _key = scn.current_token.gsub( DASH_, UNDERSCORE_ ).intern

        m = OPERATIONS__[ _key ]

        if m
          __init_selective_listener
          @_user_scanner = scn
          scn.advance_one
          send m
        else
          @serr.puts "currently, normal tmx is deactivated -"
          @serr.puts "won't parse #{ scn.current_token.inspect }"
          invite_to_general_help
        end
      end

      OPERATIONS__ = {
        map: :__bound_call_for_map,
        reports: :__bound_call_for_reports,
        test_all: :__bound_call_for_test_all,
      }

      OPERATION_DESCRIPTIONS__ = {
        test_all: :__describe_test_all,
        reports: :__describe_reports,
        map: :__describe_map,
      }

      # -- test all

      def __describe_test_all y
        y << "[ts] \"slowie\"'s high level test running and reporting operations"
      end

      def __bound_call_for_test_all

        @_express = :__express_for_test_all

        @routes = {  # how we ignore particular emissions
          find_command_args: :__receive_find_command_args,
        }

        @_table_schema = nil  # gets set by an emission if relevant

        _init_multimode_argument_scanner do |o|
          o.user_scanner remove_instance_variable :@_user_scanner
          o.listener @listener
        end

        _lib = Home_.lib_.test_support::Slowie

        _api = _lib::API.begin_invocation_by @argument_scanner do |api|

          _ = remove_instance_variable :@__test_file_name_pattern_by

          api.test_file_name_pattern_by( & _ )
        end

        bc = _api.to_bound_call_of_operator

        if bc
          if bc.receiver.respond_to? :test_directory_collection
            CLI::Magnetics_::BoundCall_via_TestDirectoryOrientedOperation[ bc, self ]
          else
            bc
          end
        end
      end

      # ~ emissions

      def __receive_find_command_args em_p, chan
        if @_BE_VERBOSE
          @listener[ * chan, & em_p ]
        end
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

        __init_argument_scanner_for_reports

        o.argument_scanner = @argument_scanner

        _bound_call_via_API_invocation o
      end

      def __init_argument_scanner_for_reports  # see [#ze-052]

        _init_multimode_argument_scanner do |o|

          o.front_scanner_tokens :reports

          o.subtract_primary :json_file_stream_by, release_json_file_stream_by_

          o.default_primary :execute

          o.user_scanner remove_instance_variable :@_user_scanner

          o.listener @listener
        end
        NIL
      end

      # -- map

      def __describe_map y
        y << "produces streams of nodes given queries"
        y << "(the underlying mechanics of most of the above)"
      end

      def __bound_call_for_map

        @_express = :__express_stream_of_map_nodes

        o = Home_::API.begin( & @listener )

        __init_argument_scanner_for_map

        o.argument_scanner = @argument_scanner

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

      def __init_argument_scanner_for_map  # see [#ze-052]

        _init_multimode_argument_scanner do |o|

          o.front_scanner_tokens :map  # invoke this operation when calling API

          o.subtract_primary :json_file_stream_by, release_json_file_stream_by_

          o.subtract_primary :json_file_stream  # used in testing, never in UI

          o.subtract_primary :attributes_module_by, -> { Home_::Attributes_ }

          o.subtract_primary :result_in_tree  # for now

          o.user_scanner remove_instance_variable :@_user_scanner

          o.listener @listener
        end
        NIL
      end

      # -- support for expressing results (our version of [#ze-025])

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

        if yes && 1 == d

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

      def _init_multimode_argument_scanner & defn

        @argument_scanner =
          Zerk_lib_[]::NonInteractiveCLI::MultiModeArgumentScanner.define( & defn )
        NIL
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

      def __init_selective_listener

        expsr = nil  # only build it once an emission is received
        @listener = -> * sym_a, & em_p do
          expsr ||= HardcodedEmissionExpresserForNow___.new self
          expsr.dup.invoke em_p, sym_a
        end
        NIL
      end

      def invite_to_general_help
        @serr.puts "try '#{ _program_name } -h'"
        _failed
      end

      def _program_name
        ::File.basename @program_name_string_array.last
      end

      def _formal_actions

        _st = _to_didactic_operation_name_stream

        expression_agent.calculate do
          say_formal_operation_alternation _st
        end
      end

      def _to_didactic_operation_name_stream
        Stream_.call OPERATION_DESCRIPTIONS__.keys do |sym|
          Common_::Name.via_variegated_symbol sym
        end
      end

      def expression_agent
        Zerk_lib_[]::NonInteractiveCLI::ArgumentScannerExpressionAgent.instance
      end

      def _failed
        @exitstatus = FAILURE_EXITSTATUS__
        UNABLE_
      end

      def _noop
        NOTHING_
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # -- for collaborators (e.g emission expresser, magnetics)

      def receive_data_emission data_p, channel
        :table_schema == channel[1] || fail
        @_table_schema = data_p[]
        NIL
      end

      attr_writer(
        :exitstatus,
      )

      attr_reader(
        :argument_scanner,
        :API_invocation_,
        :listener,
        :routes,
        :serr,
        :sout,
      )
    end

    # ==

    Legacy_CLI_class___ = Lazy_.call do
      self._NOT_USED
  class Legacy_CLI____ < Home_.lib_.brazen::CLI

    # we do not yet need and so are not yet worried about "our tmx" as a
    # back-leaning "reactive service". for now all of the below is in
    # service of *our* tmx CLI client. a more abstract such construction
    # is a false requirement for today. but we do have these requirements:
    #
    #   • there must be *no* sidesystem-specific knowledge *anywhere* here.

    def initialize i, o, e, pn_s_a

      disp = Home_::Models_::Reactive_Model_Dispatcher.new

      disp.fast_lookup = method :__fast_lookup

      disp.unbound_stream_builder = method :__to_unbound_stream

      super i, o, e, pn_s_a, :back_kernel, disp.to_kernel_adapter
    end

    expose_executables_with_prefix 'tmx-'

    def __fast_lookup nf

      # when the front element of the ARGV directly corresponds to a
      # sidesystem (gem), then resolution of the intended recipient is much
      # more straightforward than having to load possibly the whole tree.

      _ = Home_.installation_.participating_gem_prefix[ 0 .. -2 ]  # "skylab"

      possible_gem_path = ::File.join _, nf.as_slug

      _ok = ::Gem.try_activate possible_gem_path
      if _ok
        ___fast_lookup_when_gem possible_gem_path, nf
      else

        # (we could extend this "optimization" to the executables but meh)

        NIL_
      end
    end

    def ___fast_lookup_when_gem path, nf

      require path

      sym_a = Home_.installation_.participating_gem_const_path_head.dup

      sym_a.push nf.as_const  # EEK

      ss_mod = Autoloader_.const_reduce sym_a, ::Object

      _cli_class = ss_mod.const_get :CLI, false  # :+#hook-out

      if _cli_class

        _nf = Common_::Name.via_module ss_mod

        Home_::Model_::Showcase_as_Unbound.new _nf, ss_mod
      else
        self._COVER_ME
      end
    end

    def __to_unbound_stream

      _st = Home_.installation_.to_sidesystem_manifest_stream

      # sess.number_of_synopsis_lines = 2
      # sess.program_name_string_array = pn_s_a

      _st.expand_by do | manifest |

        manifest.to_unboundish_stream
      end
    end

    def init_properties
      super
      # (typically, is a frozen const-like thing so..)

      bx = @front_properties.dup  # (.. and not `to_mutable_box_like_proxy`)

      bx.replace_by :action do | prp |
        prp.dup_by do
          @name = Common_::Name.via_variegated_symbol :reactive_node
        end
      end
      @front_properties = bx
      NIL_
    end

    class Showcase_as_Bound

      include Home_::Model_::Common_Bound_Methods

      # make the top client look like a reactive node! eek

      def initialize bound_parent_action, nf, ss_mod, & oes_p
        @_bound_parent = bound_parent_action
        @nf_ = nf
        @_ss_mod = ss_mod
      end

      def receive_show_help parent

        _cli = _build_new_CLI_for_under parent

        _cli.invoke [ '--help' ]  # le meh
      end

      def description_proc_for_summary_under _
        description_proc
      end

      def description_proc
        ss_mod = @_ss_mod
        -> y do
          ss_mod.describe_into_under y, self
        end
      end

      def bound_call_under ada

        _cli = _build_new_CLI_for_under ada

        _args = [ ada.resources.argv ]

        Common_::Bound_Call[ _args, _cli, :invoke ]
      end

      def _build_new_CLI_for_under ada

        rsx = ada.resources

        _slug = @nf_.as_slug

        _s_a = [ * rsx.invocation_string_array, _slug ]

        cli = @_ss_mod::CLI.new rsx.sin, rsx.sout, rsx.serr, _s_a

        if rsx.has_bridges
          self._TRIVIALLY_WRITE_AND_COVER_ME
          cli.resources.share_bridge_resources_of rsx
        end

        cli
      end
    end

    self  # legacy CLI class
  end
    end  # proc that wraps legacy CLI class

    # ==

    class HardcodedEmissionExpresserForNow___

      # this stays very close to its only client. is a separate class only
      # so that it can have a clean, dedicated ivar space per emission.
      #
      # (everything is built lazily because the variety of shapes of
      # emission we receive (event, expression, data) all use different
      # resources.)

      def initialize client
        @_ = client
        @_info_yielder = Lazy_.call { Build_info_yielder___[ client.serr ] }  # share the same across dups
        @routes = client.routes || MONADIC_EMPTINESS_
      end

      def invoke em_p, sym_a
        @channel_symbol_array = sym_a
        @emission_proc = em_p
        m = @routes[ @channel_symbol_array.last ]
        if m
          @_.send m, em_p, sym_a
        elsif :expression == @channel_symbol_array[1]
          __express_expression
        elsif :data == @channel_symbol_array[0]
          __send_data
        else
          __express_event
        end
        __maybe_invite
        NIL
      end

      def __express_event
        _ev = @emission_proc.call
        _ev.express_into_under @_info_yielder[], @_.expression_agent
        NIL
      end

      def __express_expression
        @_.expression_agent.calculate @_info_yielder[], & @emission_proc
        NIL
      end

      def __maybe_invite
        if :parse_error == @channel_symbol_array[2]
          @_.invite_to_general_help  # ..
        elsif :error == @channel_symbol_array[0]
          @_.exitstatus = FAILURE_EXITSTATUS__
        end
        NIL
      end

      def __send_data
        @_.receive_data_emission @emission_proc, @channel_symbol_array
        NIL
      end
    end

    # ==

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

    CLI_support_ = Lazy_.call do
      Home_.lib_.brazen::CLI_Support
    end

    # ==

    FAILURE_EXITSTATUS__ = 5
    HELP_RX = /\A--?h(?:e(?:lp?)?)?\z/
    SUCCESS_EXITSTATUS__ = 0

    # ==
  end  # end new CLI class
end
