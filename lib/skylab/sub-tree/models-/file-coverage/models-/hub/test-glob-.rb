module Skylab::SubTree

  class Models::Hub

    class Test_glob_

      LIB_.funcy_globless self

      def initialize x_a
        @test_dir_pn, @sub_path_a, @local_test_pathname_a = x_a
      end

      def execute
        sa = get_sub_hub
        @local_test_pathname_a.map { |pn| sa.join( pn ).to_s }
      end

    private

      def get_sub_hub
        if @sub_path_a
          @test_dir_pn.join( @sub_path_a.join SEP_ )
        else
          @test_dir_pn
        end
      end
    end
  end
end
