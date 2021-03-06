module Skylab::TestSupport

  module FileCoverage

    class Magnetics_::CompoundTree_via_Classifications

      Attributes_actor_.call( self,
        :classifications,
        :path,
        :test_dir,
        :name_conventions,
        :fs,
      )

      def initialize & p
        @on_event_selectively_ = p
      end

      def execute
        extend EXTEND___.fetch( @classifications.shape ).call
        execute
      end

      EXTEND___ = {
        directory: -> { This__::Shape_that_Is_Directory },
        file: -> { This__::Shape_that_Is_File },
      }

      def init
        bhd = ::File.dirname @test_dir
        @asset_local_range_ = tailer_range_via_path_ bhd
        @business_hub_dir_ = bhd
        NIL_
      end

      def tailer_range_via_path_ path
        path.length + 1 .. -1
      end

      This__ = self
    end
  end
end
# :+#tombstone underwent a refactor exemplary of :+[#bs-015] begin/end hax
