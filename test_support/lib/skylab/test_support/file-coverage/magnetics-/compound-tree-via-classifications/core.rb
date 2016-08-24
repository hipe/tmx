module Skylab::TestSupport

  module FileCoverage

    class Magnetics_::CompoundTree_via_Classifications

      Attributes_actor_.call( self,
        :cx, # classifications
        :path,
        :test_dir,
        :name_conventions,
        :fs,
      )

      def execute

        @nc = @name_conventions ; @name_conventions = nil

        extend EXTEND___.fetch( @cx.shape ).call

        execute
      end

      EXTEND___ = {
        directory: -> { This__::Shape_that_Is_Directory },
        file: -> { This__::Shape_that_Is_File },
      }

      def init

        bhd = ::File.dirname @test_dir

        @asset_local_range_ = produce_local_range_ bhd

        @business_hub_dir_ = bhd

        NIL_
      end

      def produce_local_range_ path
        path.length + 1 .. -1
      end

      This__ = self
    end
  end
end
# :+#tombstone underwent a refactor exemplary of :+[#bs-015] begin/end hax
