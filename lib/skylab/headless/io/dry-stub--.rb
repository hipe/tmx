module Skylab::Headless

  module IO

    class Dry_Stub__  # getting a good dry run

      def open mode
        WRITE_MODE_ == mode || APPEND_MODE_ == mode or fail say_fail mode
        yield self
      end

      def puts *a
      end

      def write s
        "#{ s }".length
      end

    private

      def say_fail mode_s
        "sanity - expected #{ WRITE_MODE_ } or #{ APPEND_MODE_ } had #{ mode_s }"
      end
    end

    APPEND_MODE_ = 'a'.freeze

    DRY_STUB__ = Dry_Stub__.new  # class as singleton [#sl-126]

  end
end
