module Skylab::BeautySalon

  class Models_::Ping

    class << self
      def describe_into_under y, expag
        expag.calculate do
          y << "tests basic wiring. #{ em 'yay.' }"
        end
      end
    end  # >>

    # -

      def initialize
        @listener = yield.listener
      end

      def execute
        @listener.call :info, :expression, :hello do |y|
          y << "[bs] says #{ em 'hello' }"
        end
        :hello_from_beauty_salon
      end
    # -

    Actions = nil  # provision [#pl-011.3] (we are the action)

  end
end
# #born. (note a [br]-era ping implementation preceded this by years)
