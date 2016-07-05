module Skylab::Task::TestSupport

  module Magnetics::CLI

    def self.[] tcc
      tcc.send :define_singleton_method, :given do |*|
      end
    end

    def _WAS
      Require_zerk_[]
      Zerk_.test_support::Non_Interactive_CLI[ tcc ]
      tcc.include self
    end

    def subject_CLI
      Home_::Magnetics::CLI
    end

    def begin_mock_FS_
      Mock_FS___.new
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
