module Skylab::GitViz

  class ScaleTime_

    class Scale_Adapters_::Daily < Here_::CommonScaleAdapter_

          class << self

            def next
              :Weekly
            end

            def day_of_week_within_ sumzn

              send :"__DOW_within__#{ sumzn.width }__", sumzn
            end

            def __DOW_within__4__ sumzn

              sumzn.downstream <<
                ( sumzn.subject.normal_datetime.strftime DOW_FORMAT___ )

              NIL_
            end

            def mday_within_ sumzn

              send :"__mday_within__#{ sumzn.width }__", sumzn
            end

            def __mday_within__4__ sumzn

              d = sumzn.subject.normal_datetime.mday

              sumzn.downstream << (
                MDAY_FORMAT___ % [ d, Home_.lib_.basic::Number::EN.ord( d ) ] )

              NIL_
            end

          end  # >>

          DAYS_PER_BUCKET = 1

          DOW_FORMAT___ = ' %a'

          INTERNAL_UNIT = :day

          MDAY_FORMAT___ = '%2d%s'

          def initialize( * )

            @state = :beginning
            super
          end

          def within_when_content_ sumzn

            send :"__after__#{ @state }__", sumzn
          end

          def __after__beginning__ sumzn

            @state = :month
            sumzn.downstream << _month_string_within( sumzn )
            NIL_
          end

          def __after__month__ sumzn

            @state = :mday

            _mday_within sumzn

            NIL_
          end

          def __after__mday__ sumzn

            o = sumzn.subject

            if o.has_content

              if o.normal_datetime.wday.zero?

                _sunday sumzn
              else

                _day_of_week_within sumzn

              end
            else

              @state = :post_empty

              sumzn.downstream << nil
            end

            NIL_
          end

          def within_when_no_content_ sumzn

            o = sumzn.subject

            if sumzn.prev.normal_datetime.year == o.normal_datetime.year

              if o.normal_datetime.wday.zero?

                _sunday sumzn
              else

                sumzn.downstream << nil
              end
            else

              Scale_Adapters_::Annual.within_ sumzn
            end
            NIL_
          end

          def _sunday sumzn

            s_a = sumzn.downstream

            if s_a.last.nil?  # HACK rewrite the past

              s_a[ -1 ] = _month_string_within sumzn

              _mday_within sumzn
            else

              _day_of_week_within sumzn
            end
            NIL_
          end

          def _month_string_within sumzn

            s = Scale_Adapters_::Monthly.string_within_ sumzn
            orig_len = s.length
            s.strip!
            d = orig_len - s.length
            if d.nonzero?
              s = "#{ s }#{ SPACE_ * d }"
            end
            s
          end

          def _mday_within sumzn

            self.class.mday_within_ sumzn
          end

          def _day_of_week_within sumzn

            self.class.day_of_week_within_ sumzn
          end
    end
  end
end
