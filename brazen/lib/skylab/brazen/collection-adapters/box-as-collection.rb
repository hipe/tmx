module Skylab::Brazen

  class Collection_Adapters::Box_as_Collection

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
