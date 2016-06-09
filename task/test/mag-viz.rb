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

    def subject_module_
      Home_::MagneticsViz
    end
  end
end
