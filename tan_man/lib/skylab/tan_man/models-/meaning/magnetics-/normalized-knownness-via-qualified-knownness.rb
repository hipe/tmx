module Skylab::TanMan

  class Models_::Meaning

    module Magnetics_

      NormalizedKnownness_via_QualifiedKnownness = ::Module.new

      class NormalizedKnownness_via_QualifiedKnownness::Name

        Actor_.call( self,
          :qualified_knownness,
        )

        def execute

          if VALID_NAME_RX__ =~ @qualified_knownness.value_x
            @qualified_knownness.to_knownness
          else
            when_invalid
          end
        end

        def when_invalid
          @on_event_selectively.call :error, :invalid_property_value do
            Common_::Event.inline_not_OK_with :invalid_meaning_name,
                :meaning_name, @qualified_knownness.value_x do | y, o |
              y << "invalid meaning name #{ ick o.meaning_name } - meaning names #{
               }must start with a-z followd by [-a-z0-9]"
            end
          end
          UNABLE_
        end

        VALID_NAME_RX__ = /\A[a-z][-a-z0-9]*\z/
      end

      # ==

      class NormalizedKnownness_via_QualifiedKnownness::Value

        Actor_.call( self,
          :qualified_knownness,
        )

        def execute
          @x = @qualified_knownness.value_x
          if NL_RX__ =~ @x
            when_invalid
          else
            when_valid
          end
        end
        NL_RX__ = /[\r\n]/

        def when_invalid
          @on_event_selectively.call :error, :invalid_property_value do
            Common_::Event.inline_not_OK_with :invalid_meaning_name,
                :meaning_value, @x do | y, o |
              y << "value cannot contain newlines."
            end
          end
          UNABLE_
        end

        def when_valid
          s = @x.strip
          d = @x.length - s.length
          if d.nonzero?
            report_strip d
            @x = s
          end
          @qualified_knownness.to_knownness
        end

        def report_strip d
          @on_event_selectively.call :info, :value_changed_during_normalization do
            Common_::Event.inline_neutral_with :value_changed_during_normalization do | y, o |
              y << "trimming #{ d } char#{ s d } of whitespace from value"
            end
          end
        end
      end

      # ==
      # ==
    end
  end
end