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
          st = bc.receiver.send bc.method_name, * bc.args, & bc.block
          if st
            @exitstatus ||= SUCCESS_EXITSTATUS__
            x = st.gets
            if x

              o = CLI::Magnetics_::
                MapItemExpresser_via_Client_and_FirstItem_and_Options.begin(
                  self, x )
              # ..

              express = o.execute

              begin
                express[ x ]
                x = st.gets
                x ? redo : break
              end while above
            else
              @serr.puts "(no results.)"  # #not-covered
            end
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
        m = OPERATIONS___[ scn.current_token.intern ]
        if m
          @__user_scanner = scn
          scn.advance_one
          send m
        else
          @serr.puts "currently, normal tmx is deactivated -"
          @serr.puts "won't parse #{ scn.current_token.inspect }"
          _invite_to_general_help
        end
      end

      OPERATIONS___ = {
        map: :__when_map,
      }

      def __when_map

        __init_selective_listener

        o = Home_::API.begin( & method( :__receive_map_emission ) )

        o.argument_scanner = __flush_argument_scanner_for_map

        @API_invocation_ = o

        o.to_bound_call
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
      #     will attempt to interpret this scanner in an "API way".

      def __flush_argument_scanner_for_map

        as = Home_.lib_.zerk::NonInteractiveCLI::MultiModeArgumentScanner.define do |o|

          o.front_scanner_tokens :map  # invoke this operation when calling API

          _ = remove_instance_variable( :@__json_file_stream_proc ).call
          o.subtract_primary :json_file_stream, _

          o.subtract_primary :attributes_module_by, -> { Home_::Attributes_ }

          o.subtract_primary :result_in_tree  # for now

          o.user_scanner remove_instance_variable :@__user_scanner

          o.listener method :__receive_argument_scanner_emission
        end

        @__argument_scanner = as

        as
      end

      def __receive_argument_scanner_emission * i_a, & em_p
        send WHEN__.fetch i_a.last
      end

      def __receive_map_emission * i_a, & ev_p
        m = WHEN__[ i_a.last ]
        if m
          send m
        else
          @_emit[ * i_a, & ev_p ]
        end
        NIL
      end

      # --

      # when any of:
      #
      #   - the [ze] argument scanner adapter (adapting from the "CLI way"
      #     to the "API way") expects to scan a primary but the current
      #     token doesn't start with a "-" (DASH) OR
      #
      #   - that same adapter encounters a well-formed primary-looking
      #     token BUT the backend knows of no primary by that name OR
      #
      #   - that same adapter encounters a well-formed, existent primary
      #     in the user ARGV but that primary has been "subtracted" from
      #     use;
      #
      # we want that the expression behavior of our UI is *identitcal* for
      # all the above cases. as such we need to override the default
      # expression behavior that occurrs variously in the [ze] adapter and
      # our own API operation for the above cases.
      #
      #   - for cases where the [ze] adapter would have done the expression,
      #     we are overriding default, minimal ("stub") expression behavior.
      #
      #   - for cases where we are overriding our own backend API opertion
      #     expression behavior, we are doing so in part because the API
      #     operation does a levenshtein (or not) explication of all available
      #     modifiers, including any that have been subtracted here. we don't
      #     want the API space to have to know about what "subtraction" even
      #     is, so instead we just override the emission, in a perfect (if
      #     somewhat weedy) utilization of our event model.

      WHEN__ = {
        subtracted_primary_referenced: :__when_subtracted,
        unknown_primary_or_operator: :__when_unknown,
        unrecognized_primary: :__when_unrecognized,
      }

      def __when_subtracted
        _when_bad_primary  # hi.
      end

      def __when_unknown
        _when_bad_primary  # hi.
      end

      def __when_unrecognized
        _when_bad_primary  # hi.
      end

      def _when_bad_primary

        op = @API_invocation_.operation_session

        subtract = @__argument_scanner.subtraction_hash

        _use_these = op.get_primary_keys.reject do |sym|
          subtract[ sym ]
        end

        op.when_unrecognized_primary -> { _use_these }, @_emit

        NIL
      end

      # --

      def __init_selective_listener

        y = Lazy_.call do
          ::Enumerator::Yielder.new do |s|
            @serr.puts s  # hi.
          end
        end

        @_emit = -> * i_a, & p do
          if :eventpoint == i_a[0]
            send i_a.fetch 1
          else
            _expression_agent.calculate y[], & p
            if :parse_error == i_a[2]
              _invite_to_general_help
            elsif :error == i_a.first
              @exitstatus = FAILURE_EXITSTATUS__
            end
          end
          NIL
        end
        NIL
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
        ExpressionAgent___.instance
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

    class ExpressionAgent___

      class << self
        def instance
          @___instance ||= new
        end
        private :new
      end  # >>

      alias_method :calculate, :instance_exec

      def say_formal_operation_alternation_ st
        _say_name_alternation :_say_slug, st
      end

      def say_primary_alternation_ st
        _say_name_alternation :say_primary_, st
      end

      def _say_name_alternation m, st

        p = method m

        _mid = st.join_into_with_by "", " | " do |name|
          p[ name ]  # hi.
        end

        "{ #{ _mid } }"
      end

      def say_arguments_head_ name
        name.as_slug.inspect
      end

      def say_primary_ name
        "#{ DASH_ }#{ name.as_slug }"
      end

      def say_strange_primary_ name
        name.as_slug.inspect
      end

      def _say_slug name
        name.as_slug
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
