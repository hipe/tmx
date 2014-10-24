module Skylab::Headless

  module IO

    class Dry_Stub__  # getting a good dry run

      def open mode
        WRITEMODE_ == mode || APPENDMODE__ == mode or fail say_fail mode
        yield self
      end

      def puts *a
      end

      def write s
        "#{ s }".length
      end

    private

      def say_fail mode_s
        "sanity - expected #{ WRITEMODE_ } or #{ APPENDMODE__ } had #{ mode_s }"
      end
    end

    APPENDMODE__ = 'a'.freeze

    DRY_STUB__ = Dry_Stub__.new  # class as singleton [#sl-126]

  end
end
