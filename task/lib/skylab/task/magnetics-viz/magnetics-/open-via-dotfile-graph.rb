class Skylab::Task

  module MagneticsViz

    class Magnetics_::Open_via_DotfileGraph

      def initialize dg, fs
        @dotfile_graph = dg
        @filesystem = fs
      end

      def execute

        fh = @filesystem.open 'tmp.dot', ::File::CREAT | ::File::WRONLY
        fh.truncate 0
        @dotfile_graph.express_into_under fh, NOTHING_
        fh.close

        ::Kernel.exec 'open', fh.path
      end
    end
  end
end
