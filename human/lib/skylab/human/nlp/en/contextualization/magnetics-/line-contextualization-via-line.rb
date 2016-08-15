module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Line_Contextualization_via_Line  # referenced 1x

      # a low level *MUST-VISIT* map to simply:
      #
      #   - temporarily remove and memo any parenthesis or similar and
      #     related, like trailing newlines then
      #
      #   - normalize received string content so it is receptive to
      #     contextualization (i.e make the first uppcase letter lowercase
      #     if it looks OK to do) then
      #
      #   - yield to the contextualizing client (typically the client
      #     adds something to the beginning and/or end of the string,
      #     thru the "parts" structure) then
      #
      #   - re-apply those any opening and closing e.g parenthesis to
      #     produce the final, contextualized *first* line.
      #
      # justification:
      #
      # any operation that we consider a "contexutalization" should want
      # this above behavior. there is no imaginable such operation that
      # would not want it. implement this behavior nowhere but here. hence
      # all pipelines must go thru this node.
      #
      # originally moved here from whatever hard-coded c15n [br] did. the
      # more interesting parts from there (the actual linguistic operations)
      # have since been abstracted to neighbor nodes and might be sunsetted.
      #
      # during #open [#043] perhaps make it compliant to that rather than
      # having this custom interface.

      class << self

        def call line
          new( line ).execute
        end
        alias_method :[], :call

        private :new
      end  # >>

      def initialize line
        @line = line
      end

      def execute

        __unparenthesize_the_line

        __downcase_the_first_letter

        Line_Contextualization___.new remove_instance_variable :@_parts
      end

      def __downcase_the_first_letter
        Mutate_by_downcasing_first___[ @_parts.normalized_original_content_string ]
        NIL_
      end

      def __unparenthesize_the_line

        o = Mutable_Line_Parts___.new

        _line = remove_instance_variable :@line

        o.open_string,
        o.normalized_original_content_string,
        o.close_string =
          Home_.lib_.basic::String.unparenthesize_message_string _line

        @_parts = o

        NIL_
      end

      # ==

      class Line_Contextualization___

        def initialize mlp
          @_mutable_line_parts = mlp  # #spot-5
        end

        def content_string_looks_like_one_word_
          LOOKS_LIKE_ONE_WORD_RX___ =~ @_mutable_line_parts.normalized_original_content_string
        end

        LOOKS_LIKE_ONE_WORD_RX___ = /\A[a-z]+$/

        def mutate_line_parts_by
          yield @_mutable_line_parts
          NIL_
        end

        def to_string__
          @_mutable_line_parts.values.join EMPTY_S_
        end
      end

      # ==

      Mutable_Line_Parts___ = ::Struct.new(  # :#spot-5
        :open_string,
        :prefixed_string,
        :normalized_original_content_string,
        :suffixed_string,
        :close_string,
      )

      # ==

      Mutate_by_downcasing_first___ = -> do
        rx = nil
        -> s do
          if s
            rx ||= /\A[A-Z](?![A-Z])/
            s.sub! rx do | s_ |
              s_.downcase!
            end
            NIL_
          end
        end
      end.call
    end
  end
end
# #history: the was extracted from [br] CLI
