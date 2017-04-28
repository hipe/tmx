module Skylab::TanMan

  class Models_::Ping

    # -

      def definition ; [
        :branch_description, -> y do
          y << "pings tanman (lowlevel)"
        end,
      ] end

      def initialize
        extend Home_::Model_::CommonActionMethods
        init_action_ yield
      end

      def execute

        _event = __build_ping_event  # (conventially built lazily, but we want to fail early)

        _listener_.call :info, :ping do
          _event
        end

        :hello_from_tan_man
      end

      def __build_ping_event

        _am = _invocation_resources_.application_moniker

        Common_::Event.inline_neutral_with(
          :ping
        ) do |y, o|
          y << "#{ _am } says #{ em 'hello' }"
        end
      end

    # -

    Actions = NOTHING_  # see [#pl-011.3]
  end
end
# #history: broke out of "workspace" actions during transition to [ze]
