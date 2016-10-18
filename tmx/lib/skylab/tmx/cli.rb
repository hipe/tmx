module Skylab::TMX

  class CLI

    Invocation___ = self

    class Invocation___

      def initialize i, o, e, pn_s_a
        @serr = e
        @sout = o
        @program_name_string_array = pn_s_a
      end

      def invoke argv
        @exitstatus = 0
        @argv = argv
        bc = __bound_call
        if bc
          st = bc.receiver.send bc.method_name, * bc.args, & bc.block
          if st
            y = ::Enumerator::Yielder.new( & @sout.method( :puts ) )
            begin
              x = st.gets
              x || break
              x.express_into y
              redo
            end while above
          end
        end
        @exitstatus
      end

      def __bound_call

        if @argv.length.nonzero? && Looks_like_option[ @argv.first ]
          __when_looks_like_option_at_front
        else
          __init_selective_listener
          o = Home_::API.begin( & @_emit )
          o.argument_scanner = ArgumentScanner___.new @argv
          o.to_bound_call
        end
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
        io.puts "usage #{ _program_name } #{ _formal_actions } [opts]"
        io.puts
        io.puts "description: experiment.."
        NIL
      end

    # --

      def __init_selective_listener

        y = Lazy_.call do
          ::Enumerator::Yielder.new do |s|
            @serr.puts s
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

        _st = Home_::API.to_didactic_operation_name_stream__

        _expression_agent.calculate do
          say_formal_argument_alternation_ _st
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

    class ArgumentScanner___

      # an attempt to allow implementation of the fully customized parsing
      # syntax (that should not be abstracted) of the map operation in such
      # a manner that allows the same syntax implementation to adapt to both
      # the CLI and API modalities..

      def initialize argv
        if argv.length.zero?
          @no_unparsed_exists = true
        else
          @scn = Common_::Polymorphic_Stream.via_array argv
        end
      end

      def advance_one  # same as sibling
        @scn.advance_one
        @no_unparsed_exists = @scn.no_unparsed_exists
        @_cache_ = nil
      end

      def head_as_agnostic
        _head_as_name
      end

      define_singleton_method :cached, DEFINITION_FOR_THE_METHOD_CALLED_CACHED_

      cached :head_as_normal_symbol do
        _head_as_name.as_lowercase_with_underscores_symbol
      end

      cached :_head_as_name do
        Common_::Name.via_slug @scn.current_token
      end

      attr_reader(
        :no_unparsed_exists,
      )
    end

    # ==

    class ExpressionAgent___

      class << self
        def instance
          @___instance ||= new
        end
        private :new
      end  # >>

      alias_method :calculate, :instance_exec

      def say_formal_argument_alternation_ st

        _mid = st.join_into_with_by "", " | " do |name|
          name.as_slug
        end

        "{ #{ _mid } }"
      end

      def say_agnostic_token_ name
        name.as_slug.inspect
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

    # ==
  end  # end new CLI class
end
