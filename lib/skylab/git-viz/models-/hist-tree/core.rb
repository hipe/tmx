module Skylab::GitViz

  Models_ = ::Module.new  # ~ :+#stowaway (IFF all models in this file)

  Action_ = GitViz_.lib_.brazen.model.action_class

  module Models_::Ping

    def self.is_silo
      true
    end

    Actions = ::Module.new

    Actions::Ping = -> secret_x=nil, bnd do

      if secret_x
        "hi: #{ secret_x }"
      else

        bnd.maybe_receive_event :info, :expression, :ping do | y |

          y << "hello from #{ bnd.kernel.app_name }."
        end

        :hello_from_git_viz
      end
    end
  end

  module Models_::HistTree

    class << self

      def is_silo
        true
      end
    end

    Actions = ::Module.new

    class Actions::Hist_Tree < Action_

      @is_promoted = true


      # attribute :pathname, pathname: true, default: '.'

      # def execute
      #   _VCS_front
      #   GitViz_::Models_::File_Node[
      #     :pathname, @pathname, :VCS_front, @VCS_front ]
    end

    Models_ = ::Module.new  # again

    class Models_::File_Node

      if false
      GitViz_.lib_.tree.enhance_with_module_methods_and_instance_methods self
      end

      def self.[] * x_a
        self._LOOK
        Actors_::Build_tree_node x_a do |bld|
          file_node = from :node_identifiers, bld.get_trail_a
          file_node.commitpoint_manifest = bld.commitpoint_mani
          file_node
        end
      end

      def set_node_payload x
        @repo_trail = x ; nil
      end

      attr_reader :repo_trail

      attr_accessor :commitpoint_manifest

      def some_commitpoint_manifest
        @commitpoint_manifest or fail 'sanity'
      end
    end

    Actors_ = ::Module.new

    class Actors_::Build_tree_node

      if false
      GitViz_.lib_.basic_Set self,
        :with_members, %i( pathname VCS_front ).freeze,
        :initialize_basic_set_with_iambic
      end

      def self.build_tree_node x_a, & p
        new( x_a, p ).build_tree_node
      end

      def initialize x_a, p
        initialize_basic_set_with_iambic x_a
        @client_p = p
      end

      def build_tree_node
        pre_execute && @client_p[ self ]
      end

    private

      def pre_execute
        procure_repo && procure_bunch
      end
      def procure_repo
        @repo = @VCS_front.procure_repo_from_pathname @pathname
        @repo && true
      end
      def procure_bunch
        @bunch = @repo.build_hist_tree_bunch
        @bunch && true
      end

    public

      def get_trail_a
        @bunch.get_trail_stream.to_a
      end

      def commitpoint_mani
        @repo.sparse_matrix
      end
    end
  end
end
