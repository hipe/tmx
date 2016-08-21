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
        @extended = false
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

      def __extended__component_association

        yield :description, -> y do
          y << "interpret the path as `<require lib><const>.<method>`, e.g"
          y << "  `skylab/human::Skylab::Human::NLP::EN::Contextualization.collection`"
          y << "this option exists to accomodate collections that make runtime"
          y << "mutations beyond just what can be isomorphed from the filesystem."
          y << "the const must be fully qualified (start with `::`)."
          y << "(at present) the method call cannot take any arguments."
          y << "the lib will be required and then the method will be sent"
          y << "to the object referenced by the const to resolve the collection."
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
          o.path_is_a_call_spec = @extended
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
        :path_is_a_call_spec,
      )

      def execute

        line_stream = __line_stream

        if @do_open
          @filesystem = ::File  # ..
          __oh_boy line_stream
        else
          line_stream
        end
      end

      def __oh_boy line_stream

        fh = @filesystem.open 'tmp.dot', ::File::CREAT | ::File::WRONLY
        fh.truncate 0

        begin
          line = line_stream.gets
          line || break
          fh << line
          redo
        end while nil

        fh.close

        path = fh.path
        @_oes_p.call :info, :expression, :attempting_to_open do |y|
          y << "(attempting to open #{ pth path })"
        end

        ::Kernel.exec 'open', path
        Home_._NEVER_SEE
      end

      def __line_stream
        if @path_is_a_call_spec
          __line_stream_when_path_is_call_spec
        else
          __line_stream_when_path_is_directory
        end
      end

      def __line_stream_when_path_is_call_spec

        _spec_s = remove_instance_variable :@path
        spec = Call_Spec___.__via_string _spec_s

        require spec.require_lib

        _broseph = spec.const_symbol_array.reduce ::Object do |m, x|
          m.const_get x, false
        end

        _col = _broseph.send spec.method

        _line_stream_via_collection _col
      end

      def __line_stream_when_path_is_directory
        o = Here_::Magnetics_
        _path = remove_instance_variable :@path
        _dir = remove_instance_variable( :@directory_class ).new _path
        _tss = o::TokenStreamStream_via_DirectoryObject[ _dir ]
        _col = o::ItemTicketCollection_via_TokenStreamStream[ _tss ]
        # (wants [#005])
        _line_stream_via_collection _col
      end

      def _line_stream_via_collection col
        _fi = col.function_index_
        Here_::Magnetics_::DotfileGraph_via_FunctionIndex[ _fi ]
      end
    end

    # ==

    class Call_Spec___

      class << self

        def __via_string s
          # because we want to allow the path to be absolutely any
          # nonzero-length string, we parse the spec from the end WEEE

          scn = Home_.lib_.string_scanner.new s.reverse

          method = scn.scan( %r([a-z0-9_]*)i ).reverse
          scn.skip %r(\.) or fail
          _const = scn.scan( %r((?:[a-zA-Z0-9_]*[A-Z]::)+) ).reverse
          require_lib = scn.scan( %r(\A.+)m ).reverse
          scn.eos? || fail
          s_a = _const.split '::'
          s_a.shift
          _sym_a = s_a.map( & :intern )
          new method.intern, _sym_a, require_lib
        end

        private :new
      end  # >>

      def initialize method, const_sym_a, require_lib
        @const_symbol_array = const_sym_a
        @method = method
        @require_lib = require_lib
      end

      attr_reader(
        :const_symbol_array,
        :method,
        :require_lib,
      )
    end

    # --

    Require_zerk_ = Lazy_.call do
      Zerk_ = Home_.lib_.zerk ; nil
    end
  end
end
# #history: subsumed the "open" magnetic
