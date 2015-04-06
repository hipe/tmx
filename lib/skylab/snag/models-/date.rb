module Skylab::Snag

  class Models_::Date

    class << self

      def normalize_argument arg, & oes_p  # :+[#ba-027]

        if arg.is_known_known

          if RX__ =~ arg.value_x
            arg
          else
            oes_p.call :error, :invalid_date do
              __build_invalid_date_event arg.value_x
            end
          end
        end
      end

      def __build_invalid_date_event x

        Callback_::Event.inline_not_OK_with :invalid_date, :x, x do | y, o |
          y << "invalid date: #{ ick o.x }"
        end
      end
    end  # >>

    RX___ = %r{ \A \d{4} - \d{2} - \d{2} \z }x

    Actions = THE_EMPTY_MODULE_

    def initialize x
      self._CHECK_THIS
      @x = x
    end
  end
end
