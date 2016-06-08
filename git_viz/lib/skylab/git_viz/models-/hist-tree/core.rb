module Skylab::GitViz

  Models_ = ::Module.new  # ~ :+#stowaway (IFF all models in this file)

  Action_ = Home_.lib_.brazen::Action

  # ->

    Models_::Ping = -> on_channel=nil, secret_x=nil, bnd, & oes_p do

      if secret_x
        "hi: #{ secret_x }"

      else

        _chn = if on_channel
          on_channel.intern
        else
          :info
        end

        oes_p.call _chn, :expression, :ping do | y |

          y << "hello from #{ bnd.kernel.app_name }."
        end

        :hello_from_git_viz
      end
    end

    # <-

  class Models_::HistTree

    def initialize x, repo

      # we are not a controller, just a model IFF every action is promoted

      @bundle = x
      @repo = repo
    end

    attr_reader :repo, :bundle

    Actions = ::Module.new

    class Actions::Hist_Tree < Action_

      @is_promoted = true

      Home_.lib_.brazen::Modelesque.entity( self,

        :property, :stderr,  # progressive output of building large hist-trees

        :required, :property, :filesystem,

        :required, :property, :system_conduit,

        :required, :property, :VCS_adapter_name,

        :required, :property, :path,
      )

      def produce_result

        ok = __resolve_VCS_adapter
        ok &&= __via_VCS_adapter_resolve_repo
        ok &&= __via_repo_resolve_mutable_VCS_bundle
        ok and Hist_Tree_.new @mutable_VCS_bundle, @repo
      end

      def __resolve_VCS_adapter

        _VCS_mod = Home_::VCS_Adapters_.const_get(
          Common_::Name.via_slug(
            @argument_box.fetch( :VCS_adapter_name ).to_s
          ).as_const, false )

        fro = _VCS_mod::Front.new_via_system_conduit(
          @argument_box.fetch( :system_conduit ),
          & handle_event_selectively )

        fro and begin
          @VCS_adapter = fro
          ACHIEVED_
        end
      end

      def __via_VCS_adapter_resolve_repo

        h = @argument_box.h_

        _fs = h.fetch :filesystem
        path = h.fetch :path
        _sys = h.fetch :system_conduit

        path.respond_to? :ascii_only? or self._FIXME  # towards closing [#004]
        @__path = path

        @repo = @VCS_adapter.new_repository_via( path, _sys, _fs )
        @repo && ACHIEVED_
      end

      def __via_repo_resolve_mutable_VCS_bundle

        h = @argument_box.h_

        _rsx = Ad_Hoc_Resources___.new h[ :stderr ] || NULL_STDERR___

        path = @__path
        _relpath = if @repo.path == path
          DOT_
        else
          Home_::Actors_::Relpath[ path, @repo.path ]
        end

        @mutable_VCS_bundle = @VCS_adapter.models::Bundle.build_bundle_via(
          _relpath,
          @repo,
          _rsx,
          h.fetch( :filesystem ),
          & @on_event_selectively )

        @mutable_VCS_bundle && ACHIEVED_
      end

      NULL_STDERR___ = class Null_Stderr___
        def write _
          NIL_
        end
        self
      end.new

      Ad_Hoc_Resources___ = ::Struct.new :stderr  # for now
    end

    Hist_Tree_ = self
  end
end
