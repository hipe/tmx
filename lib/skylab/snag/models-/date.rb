module Skylab::Snag

  class Models::Date

    class << self

      def normal x, delegate

        if RX__ =~ x
          x
        else
          delegate.receive_error_event new( x ).build_error_event
          UNABLE_  # (used to be a :+[#017], no longer)
        end
      end

      RX__ = %r{ \A \d{4} - \d{2} - \d{2} \z }x
    end

    def initialize x
      @x = x
    end

    def build_error_event
      Snag_::Model_::Event.inline :invalid_date, :x, @x do |y, o|
        y << "invalid date: #{ ick o.x }"
      end
    end
  end
end
