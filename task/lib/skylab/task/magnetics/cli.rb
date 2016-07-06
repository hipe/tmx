class Skylab::Task

  module Magnetics

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

    class Root_Autonomous_Component_System_  # #stowaway

      def initialize client
        @open = false
        @__filesystem_proc = client.method :filesystem
        # NOTE directory class expected for now of above (then #here)
      end

      def __open__component_association

        yield :description, -> y do
          y << "(experimental) write the dotfile to a tmpfile and open it now."
        end

        yield :flag
      end

      def __magnetics_viz__component_operation

        yield :description, -> y do
          y << "outputs a dotfile rendering the \"magnetics\" directory"
        end

        -> path, & oes_p do
          o = Visualize_Magnetics___.new( & oes_p )
          o.do_open = @open
          o.path = path
          o.directory_class = @__filesystem_proc.call  # #here
          o.execute
        end
      end
    end

    # ==

    class Visualize_Magnetics___

      # (keep heavy lifting out of here. this is for synthesizing etc.)

      def initialize & oes_p
        @do_open = false
        @_oes_p = oes_p
      end

      attr_writer(
        :do_open,
        :directory_class,
        :path,
      )

      def execute

        o = Here_::Magnetics_
        _path = remove_instance_variable :@path
        _dir = remove_instance_variable( :@directory_class ).new _path
        _tss = o::TokenStreamStream_via_DirectoryObject[ _dir ]
        _col = o::ItemTicketCollection_via_TokenStreamStream[ _tss ]
        _fi = o::FunctionIndex_via_ItemTicketCollection[ _col ]
        line_stream = o::DotfileGraph_via_FunctionIndex[ _fi ]

        # (ya #[#005])

        if @do_open
          ::Kernel._A
          Magnetics_::Open_via_DotfileGraph.new( dg, ::File ).execute
        else
          line_stream
        end
      end
    end

    # --

    Require_zerk_ = Lazy_.call do
      Zerk_ = Home_.lib_.zerk ; nil
    end
  end
end
