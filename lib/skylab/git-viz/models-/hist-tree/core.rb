module Skylab::GitViz

  Models_ = ::Module.new  # ~ :+#stowaway (IFF all models in this file)

  Action_ = GitViz_.lib_.brazen.model.action_class

  module Models_::Ping

    def self.is_silo
      true
    end

    Actions = ::Module.new

    Actions::Ping = -> on_channel=nil, secret_x=nil, bnd do

      if secret_x
        "hi: #{ secret_x }"

      else

        _chn = if on_channel
          on_channel.intern
        else
          :info
        end

        bnd.maybe_receive_event _chn, :expression, :ping do | y |

          y << "hello from #{ bnd.kernel.app_name }."
        end

        :hello_from_git_viz
      end
    end
  end

  class Models_::HistTree

    class << self

      def is_silo
        true
      end
    end  # >>

    def initialize x, repo

      # note this can be pure business IFF every action is promoted

      @repo = repo
      @VCS_bundle = x
    end

    attr_reader :VCS_bundle

    Actions = ::Module.new

    class Actions::Hist_Tree < Action_

      @is_promoted = true

      GitViz_.lib_.brazen.model.entity self,

        :required, :property, :VCS_adapter_name,

        :required, :property, :system_conduit,

        :required, :property, :path

      def produce_result
        ok = __resolve_VCS_adapter
        ok &&= __via_VCS_adapter_resolve_repo
        ok &&= __via_repo_resolve_mutable_VCS_bundle
        ok and Hist_Tree_.new @mutable_VCS_bundle, @repo
      end

      def __resolve_VCS_adapter

        _VCS_mod = GitViz_::VCS_Adapters_.const_get(
          Callback_::Name.via_slug(
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

        pn = @argument_box.fetch :path

        if ! pn.respond_to? :to_path and pn  # while [#004], let the magic happen
          pn = ::Pathname.new pn
        end

        @pathname = pn

        @repo = @VCS_adapter.new_repository_via_pathname pn
        @repo && ACHIEVED_
      end

      def __via_repo_resolve_mutable_VCS_bundle

        _short_path = @pathname.relative_path_from( @repo.pn_ ).to_path

        @mutable_VCS_bundle = @VCS_adapter.models::Bundle.build_via_path_and_repo(
          _short_path, @repo, & @on_event_selectively )

        @mutable_VCS_bundle && ACHIEVED_
      end
    end

    Hist_Tree_ = self
  end
end
