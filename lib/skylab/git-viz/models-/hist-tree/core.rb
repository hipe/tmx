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

  class Models_::HistTree  # (not used as class YET)

    class << self

      def is_silo
        true
      end
    end  # >>

    Actions = ::Module.new

    class Actions::Hist_Tree < Action_

      @is_promoted = true

      GitViz_.lib_.brazen.model.entity self,

        :required, :property, :VCS_adapter_name,

        :required, :property, :system_conduit,

        :required, :property, :path

      def produce_result
        _ok = __resolve_VCS_adapter
        _ok && __via_VCS_adapter
      end

      def __resolve_VCS_adapter

        _VCS_mod = GitViz_::VCS_Adapters_.const_get(
          Callback_::Name.via_slug(
            @argument_box.fetch( :VCS_adapter_name ).to_s
          ).as_const, false )

        fro = _VCS_mod::Front.new _VCS_mod, handle_event_selectively do | fr |
          fr.set_system_conduit @argument_box.fetch :system_conduit
        end

        fro and begin
          @VCS_adapter = fro
          ACHIEVED_
        end
      end

      def __via_VCS_adapter

        pn = @argument_box.fetch :path

        if ! pn.respond_to? :to_path and pn  # while [#004], let the magic happen
          pn = ::Pathname.new pn
        end

        Actors__::Build_tree[ pn, @VCS_adapter, & handle_event_selectively ]
      end
    end

    Actors__ = ::Module.new

    class Actors__::Build_tree

      Callback_::Actor.call self, :properties,

        :pathname, :VCS_adapter

      def execute
        ok = __resolve_repo
        ok &&= __via_repo_resolve_bunch
        ok && __flush
      end

      def __resolve_repo
        @repo = @VCS_adapter.procure_repo_from_pathname @pathname  # #todo:name
        @repo && ACHIEVED_
      end

      def __via_repo_resolve_bunch
        @bunch = @repo.build_hist_tree_bunch
        @bunch && ACHIEVED_
      end

      def __flush

        GitViz_.lib_.tree.from(
          :node_identifiers, @bunch.immutable_trail_array )
      end
    end
  end
end
