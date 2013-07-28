module Skylab::Headless

  module IO

    class Dry_Stub_  # getting a good dry run

      def open mode
        WRITEMODE_ == mode or
          fail "sanity - expected #{ WRITEMODE_ } had #{ mode }"
        yield self
      end

      def puts *a
      end

      def write s
        "#{ s }".length
      end
    end

    DRY_STUB = Dry_Stub_.new  # class as singleton [#sl-126]

  end
end
