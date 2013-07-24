module Skylab::Headless

  module IO

    class Dry_Stub_  # getting a good dry run

      def open mode
        WRITE_PLUS_ == mode or fail "sanity"
        yield self
      end
      WRITE_PLUS_ = 'w+'.freeze

      def puts *a
      end

      def write s
        "#{ s }".length
      end
    end

    DRY_STUB = Dry_Stub_.new  # class as singleton [#sl-126]

  end
end
