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

    def __fast_lookup sym

      # when the front element of the ARGV directly corresponds to a
      # sidesystem (gem), then resolution of the intended recipient is much
      # more straightforward than having to load possibly the whole tree.

      possible_gem_path =
        "#{ Home_.installation_.participating_gem_prefix[ 0 .. -2 ] }/#{ sym }"

      _ok = ::Gem.try_activate possible_gem_path
      if _ok
        require possible_gem_path
        __fast_lookup_when_gem possible_gem_path, sym
      else

        # (we could extend this "optimization" to the executables but meh)

        NIL_
      end
    end

    def __fast_lookup_when_gem path, sym

      sym_a = Home_.installation_.participating_gem_const_path_head.dup
      sym_a.push sym  # EEK
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

      def under_expression_agent_get_N_desc_lines expag, n=nil
        @_ss_mod.describe_into_under [], expag
      end

      def bound_call_via_receive_frame otr

        rsx = otr.resources

        _slug = @nf_.as_slug

        _s_a = [ * rsx.invocation_string_array, _slug ]

        cli = @_ss_mod::CLI.new rsx.sin, rsx.sout, rsx.serr, _s_a

        if rsx.has_bridges
          self._TRIVIALLY_WRITE_AND_COVER_ME
          cli.resources.share_bridge_resources_of rsx
        end

        Callback_::Bound_Call.new( [ rsx.argv ], cli, :invoke )
      end
    end
  end
end