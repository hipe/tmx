module Skylab::TMX

  class CLI < Home_.lib_.brazen::CLI

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

        _nf = Callback_::Name.via_module ss_mod

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
          @name = Callback_::Name.via_variegated_symbol :reactive_node
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

        Callback_::Bound_Call.new _args, _cli, :invoke
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
  end
end
