module Skylab::Task::TestSupport

  module Mag_Viz

    module CLI

      def self.[] tcc
        Require_zerk_[]
        Zerk_.test_support::Non_Interactive_CLI[ tcc ]
        tcc.include self
      end

      def subject_CLI
        Home_::MagneticsViz::CLI
      end
    end

    def self.[] tcc
      tcc.include self
    end

    def begin_mock_FS_
      Mock_FS___.new
    end

    def subject_module_
      Home_::MagneticsViz
    end

    # ==

    class Mock_FS___

      def initialize
        @_h = {}
      end

      def add_thing xx, & p
        @_h[ xx ] = p
      end

      def finish
        self
      end

      # --

      def entries path
        @_h.fetch( path ).call
      end
    end
  end
end
