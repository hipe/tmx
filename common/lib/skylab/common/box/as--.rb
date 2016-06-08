module Skylab::Callback

  Box::As__ = ::Module.new

  class Box::As__::Collection

    class << self

      alias_method :[], :new

      def is_actionable
        false
      end

      private :new
    end  # >>

    def initialize bx
      @_bx = bx
    end

    def to_entity_stream
      @_bx.to_value_stream
    end
  end
end

# :+#tombstone: "struct from box"
# :+#tombstone: "box as hash"
