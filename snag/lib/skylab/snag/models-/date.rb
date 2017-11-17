module Skylab::Snag

  class Models_::Date

    class << self

      def normalize_qualified_knownness qkn, & p  # #[#fi-004.5]

        if qkn.is_known_known

          if RX___ =~ qkn.value

            qkn.new_with_value new qkn.value
          else
            p.call :error, :invalid_date do
              __build_invalid_date_event qkn.value
            end
            UNABLE_
          end
        end
      end

      def __build_invalid_date_event x

        Common_::Event.inline_not_OK_with :invalid_date, :x, x do | y, o |
          y << "invalid date: #{ ick o.x }"
        end
      end
    end  # >>

    RX___ = %r{ \A \d{4} - \d{2} - \d{2} \z }x

    def initialize valid_s

      @string = valid_s.frozen? ? valid_s : valid_s.freeze
    end

    attr_reader :string

    module ExpressionAdapters
      EN = nil
    end

    # ==
  end
end
