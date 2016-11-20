module Skylab::Zerk

  module ArgumentScanner

    class CustomEmitter

      # if the client wants to customize how the emissions "express"
      # (but not how they emit) this does all the lower-level wiring.

      def initialize
        @channel_for_unknown_by = nil
        @express_unknown_by = nil
      end

      attr_writer(
        :channel_for_unknown_by,
        :express_unknown_by,
      )

      def finish
        freeze
      end

      def call idea
        dup.__init( idea ).execute
      end

      alias_method :[], :call

      def __init idea
        @idea = idea
        freeze
      end

      def execute

        if @idea.is_about_unknown_item && ( x = __customizations_about_unknown )  # etc
          __emit_customly x
        else
          @idea.emit_normally
        end
      end

      def __emit_customly x

        channel_by, express_idea_by = x
        idea = @idea

        channel = if channel_by
          channel_by[ idea ]
        else
          idea.get_channel
        end

        idea.listener.call( * channel ) do |y|

          expr = idea.to_expression_into_under y, self

          if express_idea_by
            express_idea_by[ expr ]
          else
            expr.express_normally
          end
        end

        UNABLE_
      end

      def __customizations_about_unknown
        @channel_for_unknown_by || @express_unknown_by and
          [ @channel_for_unknown_by, @express_unknown_by ]
      end
    end
  end
end
# #history: broke out of "operator branch via autoloaderized module"
