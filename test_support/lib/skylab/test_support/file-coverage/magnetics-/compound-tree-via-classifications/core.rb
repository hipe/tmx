module Skylab::SubTree

  class Models_::File_Coverage

    class Actors_::Build_compound_tree

      Attributes_actor_.call( self,
        :cx, # classifications
        :path,
        :test_dir,
        :name_conventions,
        :fs,
      )

      def execute

        @nc = @name_conventions ; @name_conventions = nil

        extend ( if :file == @cx.shape
          Build_compound_tree_::For_single_file___
        else
          Build_compound_tree_::For_directory___
        end )

        execute
      end

      def init

        bhd = ::File.dirname @test_dir

        @asset_local_range_ = produce_local_range_ bhd

        @business_hub_dir_ = bhd

        NIL_
      end

      def produce_local_range_ path
        path.length + 1 .. -1
      end

      Build_compound_tree_ = self
    end
  end
end
# :+#tombstone underwent a refactor exemplary of :+[#bs-015] begin/end hax
