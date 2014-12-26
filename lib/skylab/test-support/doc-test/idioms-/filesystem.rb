module Skylab::TestSupport

  module DocTest

    class Idioms_::Filesystem

      # this is totally frontier and primordial: experimentally an "idioms"
      # is associated with the action instance and wraps common interactions
      # with some external system into a unified interal API that can be
      # shared across the model, and may have business-specific
      # customizations in it.

      # this is done both because DRY and so we have a central façade in case
      # we ever try to mock the FS

      def initialize & oes_p

        @oes_p = oes_p

        @test_support_file_p = -> do
          a = TestSupport_::Init.test_support_filenames
          x = a.fetch( a.length - 1 << 2 )
          @test_support_file_p = -> { x }
          x
        end
      end

      def members
        [ :find_testsupport_file_upwards, :test_support_file, :file_must_exist ]
      end

      def find_testsupport_file_upwards dirname, * rest, & oes_p

        TestSupport_._lib.system.filesystem.walk(
          :start_path, dirname,
          :filename, test_support_file,
          :max_num_dirs_to_look, -1,
          :property_symbol, :directory,
          * rest,
          :on_event_selectively, ( oes_p || @oes_p ) )

      end

      def test_support_file
        @test_support_file_p[]
      end


      def file_must_exist x, & oes_p

        TestSupport_._lib.system.filesystem.normalization.upstream_IO(
          :path, x,
          :only_apply_expectation_that_path_is_ftype_of, FILE_FTYPE_,
          :on_event_selectively, ( oes_p || @oes_p ) )

      end

      FILE_FTYPE_ = 'file'.freeze
    end
  end
end