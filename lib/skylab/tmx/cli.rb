module Skylab::TMX

  class CLI < Home_.lib_.brazen::CLI

    # we do not yet need and so are not yet worried about "our tmx" as a
    # back-leaning "reactive service". for now all of the below is in
    # service of *our* tmx CLI client. a more abstract such construction
    # is a false requirement at present. but we do have these requirements:
    #
    #   • there must be *no* sidesystem-specific knowledge *anywhere* here.

    def initialize i, o, e, pn_s_a

      tmx_host_mod = ::Skylab

      filesystem = Home_.lib_.system.filesystem  # directory?, glob
      front = Home_::Models::Front.new

      front.fast_lookup = -> sym do

        Actors_::Fast_lookup.new( sym, tmx_host_mod, filesystem ).execute
      end

      front.unbound_stream_builder = -> do

        o = Home_::Sessions_::Front_Loader.new
        o.bin_path = Home_.bin_path
        o.filesystem = filesystem
        o.number_of_synopsis_lines = 2
        o.program_name_string_array = pn_s_a
        o.tmx_host_mod = tmx_host_mod
        o.execute
      end

      _kr = front.to_kernel_adapter

      super i, o, e, pn_s_a, :back_kernel, _kr
    end

    def adapter_via_unbound ada

      # always pass these thru. they come from two places, and they
      # must have been converted to adapters by now

      ada
    end

    def resolve_properties
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

    Actors_ = ::Module.new

    class Actors_::Fast_lookup

      # we don't need to walk (perhaps) the whole interface tree IFF we are
      # invoking a single reactive node and the whole slug was provided.

      def initialize * a
        @symbol, @tmx_host_mod, @filesystem = a
      end

      def execute

        # hit the real filesystem once. we aren't bothering with any of
        # our several API's yet, like autoloading and [sl]

        @_slug = @symbol.id2name.gsub UNDERSCORE_, DASH_

        if SANITY_RX___ =~ @_slug  # because filesystem
          __when_sane
        end
      end

      SANITY_RX___ = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/  # while it works

      def __when_sane

        @_path = ::File.join @tmx_host_mod.dir_pathname.to_path, @_slug

        if @filesystem.directory? @_path
          __when_directory
        end
      end

      def __when_directory

        mod = Autoloader_.const_reduce [ @_slug ], @tmx_host_mod  # block for et

        if mod.const_get :CLI, false

          Sidesystem_Module_as_Bound___.new mod
        else
          self._WE_CAN_LOOK_ELSEWHERE
        end
      end
    end

    class Sidesystem_Module_as_Bound___

      def initialize mod
        @mod = mod
      end

      def bound_call_via_receive_frame otr

        rsx = otr.resources

        _slug = Callback_::Name.via_module( @mod ).as_slug

        _s_a = [ * rsx.invocation_string_array, _slug ]

        cli = @mod::CLI.new rsx.sin, rsx.sout, rsx.serr, _s_a

        if rsx.has_bridges
          self._TRIVIALLY_WRITE_AND_COVER_ME
          cli.resources.share_bridge_resources_of rsx
        end

        Callback_::Bound_Call.new( [ rsx.argv ], cli, :invoke )
      end
    end

    DASH_ = '-'
    UNDERSCORE_ = '_'
  end
end
