module Skylab::TMX

  class CLI

    # at the moment all the the code here falls decisively into either the
    # "pre-map" or "post-map" era. "pre-map" is all commented out for now.
    # "post-map" is largely a frontier playground for exciting adaptation experiments.

    Invocation___ = self

    class Invocation___

      def initialize i, o, e, pn_s_a
        @serr = e
        @sout = o
        @program_name_string_array = pn_s_a
      end

      def json_file_stream_by & p
        @__json_file_stream_proc = p
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

          _any_of_these = say_formal_operation_alternation_ st

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
        _invite_to_general_help
      end

      def __when_general_help
        io = @serr
        io.puts "usage: #{ _program_name } #{ _formal_actions } [opts]"
        io.puts
        io.puts "description: experiment.."
        @exitstatus = SUCCESS_EXITSTATUS__
        NIL
      end

      def __when_looks_like_operation_at_front

        scn = Common_::Polymorphic_Stream.via_array @argv

        _key = scn.current_token.gsub( DASH_, UNDERSCORE_ ).intern

        m = OPERATIONS___[ _key ]

        if m
          __init_selective_listener
          @_user_scanner = scn
          scn.advance_one
          send m
        else
          @serr.puts "currently, normal tmx is deactivated -"
          @serr.puts "won't parse #{ scn.current_token.inspect }"
          _invite_to_general_help
        end
      end

      OPERATIONS___ = {
        map: :__bound_call_for_map,
        reports: :__bound_call_for_reports,
        test_all: :__bound_call_for_test_all,
      }

      # -- test all

      def __bound_call_for_test_all

        @_express = :_express_stream_of_string_or_name

        _lib = Home_.lib_.test_support::Slowie

        _as = _flush_multimode_argument_scanner do |o|
          o.user_scanner remove_instance_variable :@_user_scanner
          o.listener @_emit
        end

        invo = _lib::API.invocation_via_argument_scanner _as
        # invo.xx = :yy
        _bc = invo.to_bound_call
        _bc  # #todo
      end

      # -- reports

      def __bound_call_for_reports

        @_express = :_express_stream_of_string_or_name

        o = Home_::API.begin( & @_emit )
        o.argument_scanner = __flush_argument_scanner_for_reports
        _bound_call_via_API_invocation o
      end

      def __flush_argument_scanner_for_reports

        _flush_multimode_argument_scanner do |o|

          o.front_scanner_tokens :reports

          o.subtract_primary :json_file_stream_by, _release_json_file_stream_by

          o.default_primary :execute

          o.user_scanner remove_instance_variable :@_user_scanner

          o.listener @_emit
        end
      end

      # -- map

      def __bound_call_for_map

        @_express = :__express_stream_of_map_nodes

        o = Home_::API.begin( & method( :__receive_map_emission ) )

        o.argument_scanner = __flush_argument_scanner_for_map

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

      # the following method could stand as sort of a model for how this new,
      # "multi-mode argument scanner" adaptation could go for customizing
      # API operations as CLI operations generally. note this explanation
      # is longer than the method itself.
      #
      #   - both because we had to parse the operation name off the ARGV
      #     before we could know which operation we want to build the
      #     adaptation for AND because it's more explicit, we tell our
      #     adapter explicitly the path to the backend operation we are
      #     calling with `front_scanner_tokens`.
      #
      #   - each `subtract_primary` has the effect of making that primary
      #     not settable by the CLI. in most cases we provide a "fixed"
      #     value for it that to the backend is indistinguishable from a
      #     user-provided value.
      #
      #     (note for later: the way we used to do this in [br] was awful)
      #
      #   - finally with `user_scanner` we pass any remaining non-parsed
      #     ARGV (which, of course, is written in a "CLI way"). the adapter
      #     attempts to make the underlying user arguments available to the
      #     operation for it to read in an "API way" with name convention
      #     translation as appropriate.

      def __flush_argument_scanner_for_map

        _flush_multimode_argument_scanner do |o|

          o.front_scanner_tokens :map  # invoke this operation when calling API

          o.subtract_primary :json_file_stream_by, _release_json_file_stream_by

          o.subtract_primary :json_file_stream  # used in testing, never in UI

          o.subtract_primary :attributes_module_by, -> { Home_::Attributes_ }

          o.subtract_primary :result_in_tree  # for now

          o.user_scanner remove_instance_variable :@_user_scanner

          o.listener method :__receive_argument_scanner_emission
        end
      end

      def __receive_argument_scanner_emission * i_a, & em_p
        # hi. (used to intercept & map)
        @_emit.call( * i_a, & em_p )
        NIL
      end

      def __receive_map_emission * i_a, & ev_p
        # hi. (used to intercept & map)
        @_emit.call( * i_a, & em_p )
        NIL
      end

      # -- support for expressing results (our version of [#ze-025])

      def _express_stream_of_string_or_name st
        _express_non_empty_stream :__expresser_for_string_or_name, st
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
          @serr.puts "(no results.)"  # #not-covered
        end
        NIL
      end

      # -- preparing calls to the backend

      def _flush_multimode_argument_scanner & defn

        as = Zerk_[]::NonInteractiveCLI::MultiModeArgumentScanner.define( & defn )

        @_argument_scanner = as

        as
      end

      def _release_json_file_stream_by
        remove_instance_variable :@__json_file_stream_proc
      end

      def _bound_call_via_API_invocation o
        @API_invocation_ = o
        o.to_bound_call
      end

      # --

      def __init_selective_listener

        expsr = nil
        @_emit = -> * sym_a, & em_p do
          expsr ||= __build_emission_expresser
          expsr.dup.invoke em_p, sym_a
        end
        NIL
      end

      def __build_emission_expresser  # only build when an emission is received

        _expag = _expression_agent  # few (no?) emissions are expresssed without it
        HardcodedEmissionExpresserForNow___.new(
          method( :_invite_to_general_help ),
          -> d { @exitstatus = d },
          _expag,
          @serr,
        )
      end

      def _invite_to_general_help
        @serr.puts "try '#{ _program_name } -h'"
        _failed
      end

      def _program_name
        ::File.basename @program_name_string_array.last
      end

      def _formal_actions

        _st = _to_didactic_operation_name_stream

        _expression_agent.calculate do
          say_formal_operation_alternation_ _st
        end
      end

      def _to_didactic_operation_name_stream
        Stream_.call %w( map BLAH ) do |s|
          Common_::Name.via_slug s
        end
      end

      def _expression_agent
        Zerk_[]::NonInteractiveCLI::ArgumentScannerExpressionAgent.instance
      end

      def _failed
        @exitstatus = FAILURE_EXITSTATUS__
        UNABLE_
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      attr_reader(  # (for collaborators (e.g magnetics))
        :API_invocation_,
        :sout,
      )
    end

    # ==

    Legacy_CLI_class___ = Lazy_.call do
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

      def initialize * four

        @invite, @write_exitstatus, @expression_agent, serr = four

        @_y = ::Enumerator::Yielder.new do |s|
          serr.puts s  # hi.
        end
        freeze
      end

      def invoke em_p, sym_a
        @channel_symbol_array = sym_a
        @emission_proc = em_p
        if :expression == @channel_symbol_array[1]
          __express_expression
        else
          __express_event
        end
        __maybe_invite
        NIL
      end

      def __express_event
        _ev = @emission_proc.call
        _ev.express_into_under @_y, @expression_agent
        NIL
      end

      def __express_expression
        @expression_agent.calculate @_y, & @emission_proc
        NIL
      end

      def __maybe_invite
        if :parse_error == @channel_symbol_array[2]
          @invite[]
        elsif :error == @channel_symbol_array[0]
          @write_exitstatus[ FAILURE_EXITSTATUS__ ]
        end
        NIL
      end
    end

    # ==

     Looks_like_option = -> do
      d = DASH_.getbyte 0  # DASH_BYTE_
      -> s do
        d == s.getbyte(0)
      end
    end.call

    # ==

    FAILURE_EXITSTATUS__ = 5
    HELP_RX = /\A--?h(?:e(?:lp?)?)?\z/
    SUCCESS_EXITSTATUS__ = 0

    # ==
  end  # end new CLI class
end
