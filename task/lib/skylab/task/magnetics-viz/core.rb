class Skylab::Task

  module MagneticsViz

    module CLI

      class << self

        def new sin, sout, serr, pn_s_a

          Require_zerk_[]

          cli = Zerk_::HybridCLI.begin

          cli.root_ACS = -> do
            Root_Autonomous_Component_System_.new cli
          end

          cli.interactive_design = -> vmm do
            vmm.compound_frame = vmm.common_compound_frame
            # vmm.custom_tree_array_proc = CLI::Interactive::CUSTOM_TREE
            vmm.location = vmm.common_location
            vmm.primitive_frame = vmm.common_primitive_frame
            vmm
          end

          cli.location_module = CLI

          cli.universal_CLI_resources sin, sout, serr, pn_s_a

          cli.finish
        end
      end  # >>
    end

    class Root_Autonomous_Component_System_

      def initialize client
        @__filesystem_proc = client.method :filesystem
      end

      def __magnetics_visualize__component_operation

        yield :description, -> y do
          y << "outputs a dotfile rendering the \"magnetics\" directory"
        end

        -> path, & oes_p do
          o = Visualize_Magnetics___.new( & oes_p )
          o.path = path
          o.filesystem = @__filesystem_proc.call
          o.execute
        end
      end
    end

    # ==

    class Visualize_Magnetics___

      # (keep heavy lifting out of here. this is for synthesizing etc.)

      def initialize & oes_p
        @_oes_p = oes_p
      end

      attr_writer(
        :filesystem,
        :path,
      )

      def execute
        ok = __resolve_means_stream_via_path
        ok && __init_graph_via_means_stream
        ok && __dotfile_graph_via_graph
      end

      def __dotfile_graph_via_graph
        Magnetics_::DotfileGraph_via_Graph.new( @_graph, & @_oes_p ).execute
      end

      def __init_graph_via_means_stream
        _ = remove_instance_variable :@_means_stream
        @_graph = Magnetics_::Graph_via_MeansStream[ _ ]
        ACHIEVED_
      end

      def __resolve_means_stream_via_path

        st = Magnetics_::MeansStream_via_Path.new( @path, @filesystem, & @_oes_p ).execute
        if st
          @_means_stream = st ; ACHIEVED_
        else
          st
        end
      end
    end

    # --

    Require_zerk_ = Lazy_.call do
      Zerk_ = Home_.lib_.zerk ; nil
    end

    # --

    module Magnetics_

      Graph_via_MeansStream = -> st do
        g = Models_::Graph.begin
        begin
          me = st.gets
          me or break
          g.add_means me.slugs_B, me.slug_A
          redo
        end while nil
        g.finish
      end

      Autoloader_[ self ]
    end

    module Models_

      Means = ::Struct.new :slugs_B, :slug_A

      Autoloader_[ self ]
    end

    Here_ = self
  end
end
