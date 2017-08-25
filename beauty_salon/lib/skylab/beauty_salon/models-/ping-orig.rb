module Skylab::BeautySalon

  Require_brazen_LEGACY_[]

  # hard to explain why this file is necessary:
  #
  #   - while #open [#023], CLI2 will exist IN PARALLEL to CLI
  #
  #   - one-by-one we are transitioning items from CLI to CLI2
  #
  #   - breaking [tmx] integration during this work is not allowed
  #
  #   - as such, we need one ping to work with CLI2 and another for CLI
  #
  #   - why we can't just use the CLI2 ping under [tmx] is because
  #     [tmx] is perhaps hard-coded to mount CLI (not CLI2)

  class Models_::PingOrig < Brazen_::Action  # :+#stowaway (while it works)

      # @is_promoted = true

      def produce_result
        @on_event_selectively.call :info, :expression, :ping do | y |
          y << "hello from beauty salon."
        end
        :hello_from_beauty_salon
      end
  end
end
# #TEMPORARY FILE
