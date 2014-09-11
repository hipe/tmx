module Skylab::TanMan

  class Models_::Meaning

    module Controller__

      class Normalize_name

        Actor_[ self, :properties, :x, :val_p, :ev_p, :prop ]

        def execute
          if VALID_NAME_RX__ =~ @x
            @val_p[ @x ]
          else
            when_invalid
          end
        end

        def when_invalid
          @ev_p[ :error, :invalid_meaning_name, :meaning_name, @x, -> y, o do
            y << "invalid meaning name #{ ick o.meaning_name } - meaning names #{
             }must start with a-z followd by [-a-z0-9]"
          end ]
        end

        VALID_NAME_RX__ = /\A[a-z][-a-z0-9]*\z/
      end

      class Normalize_value

        Actor_[ self, :properties, :x, :val_p, :ev_p, :prop ]

        def execute
          if NL_RX__ =~ @x
            when_invalid
          else
            when_valid
          end
        end
        NL_RX__ = /[\r\n]/

        def when_invalid
          @ev_p[ :error, :invalid_meaning_value, :meaning_value, @x,
            -> y, o do
              y << "value cannot contain newlines."
            end ]
        end

        def when_valid
          s = @x.strip
          d = @x.length - s.length
          if d.nonzero?
            report_strip d
            @x = s
          end
          @val_p[ @x ]
        end

        def report_strip d
          @ev_p[ :info, :value_changed_during_normalization, -> y, o do
            y << "trimming #{ d } char#{ s d } of whitespace from value"
          end ]
          @ev_p[ _ev ]
        end
      end
    end
  end
end
