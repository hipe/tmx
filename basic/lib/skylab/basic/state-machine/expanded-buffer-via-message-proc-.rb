module Skylab::Basic

  class StateMachine

    class ExpandedBuffer_via_MessageProc_ < Common_::MagneticBySimpleModel

      # similar to [#028] string templates but ad-hoc.
      # we've done it somewhere before..

      # -

        def initialize
          @separator_token = nil
          super
        end

        attr_writer(
          :buffer,
          :message_proc,
          :separator,
          :session,
        )

        def execute

          p = nil

          with_separator = -> words do
            @buffer << @separator << words
          end

          without_separator = -> words do
            @buffer << words
          end

          p = -> words do
            if @separator
              p = with_separator
            else
              p = without_separator
            end
            without_separator[ words ]
          end

          _y = ::Enumerator::Yielder.new do |unexpanded_words|

            _expanded_words = unexpanded_words.gsub %r(\{\{[ ]*([a-z_]+)[ ]*\}\}) do
              __expand $~[1].intern
            end

            p[ _expanded_words ]
          end

          @message_proc[ _y ]

          @buffer
        end

        def __expand sym
          case sym
          when :state
            _ = @session.state.description_under :_ASSUMING_NO_EXPRESSION_AGENT_ba_
            Smart_quote___[ _ ]
          else
            "«#{ sym }»"  # failure failures are tedius so pass them thru
          end
        end
      # -

      # ==

      Smart_quote___ = -> s do
        # typical implementation of [#ze-041.1] "smart quotes"/"human escape"
        s.include?( SPACE_ ) ?  %("#{ s }") : s
      end

      # ==
    end
  end
end
# #born for new failure expression micro-API
