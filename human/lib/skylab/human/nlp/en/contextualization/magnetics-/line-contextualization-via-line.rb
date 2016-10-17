module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Line_Contextualization_via_Line  # referenced 1x

      # a popular choice of tool for how to implement a map of the first line:
      #
      #   - temporarily remove and memo any parenthesis or similar and
      #     related, like trailing punctuation and/or newlines then
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

        alias_method :call, :new
        alias_method :[], :call
        undef_method :new
      end  # >>

      def initialize line

        if line
          @had_original_line = true
          @__line = line
        else
          @had_original_line = false
        end

        @mutable_line_parts = Mutable_Line_Parts___.new

        if @had_original_line
          __unparenthesize_the_line
          __downcase_the_first_letter
        end
        NIL_
      end

      # --

      def string_via_phrase_assembly
        pa = Home_::PhraseAssembly.begin_phrase_builder
        yield pa
        pa.flush_to_string
      end

      def define_prefixed_string_via_inflected_parts
        ip = Here_::Models_::InflectedParts.begin
        yield ip
        @mutable_line_parts.prefixed_string = ip.to_string  # no trailing space added yet (#here)
        NIL_
      end

      # --

      def __downcase_the_first_letter
        Mutate_by_downcasing_first___[ @mutable_line_parts.normalized_original_content_string ]
        NIL_
      end

      def __unparenthesize_the_line

        o = @mutable_line_parts

        _line = remove_instance_variable :@__line

        o.open_string,
        o.normalized_original_content_string,
        o.close_string =
          Home_.lib_.basic::String.unparenthesize_message_string _line

        NIL_
      end

      # --

      def content_string_looks_like_one_word_
        LOOKS_LIKE_ONE_WORD_RX___ =~ @mutable_line_parts.normalized_original_content_string
      end

      LOOKS_LIKE_ONE_WORD_RX___ = /\A[a-z]+$/

      attr_reader(
        :had_original_line,
        :mutable_line_parts,
      )

      # --

      def to_string

        # NOTE that the orginal content string is not a given: we allow that
        # the "first line map" is passed a false-ish to produce a string that
        # rather than being a modified form of the original string, is
        # sufficient as a standalone sentence phrase (#c15n-test-family-1).
        #
        # without the "magic spacing" we are about to describe below, the
        # "idiom designer" would have to know whether or not there is an
        # original string being modified in order to determine whether she
        # needs an interceding space between (for example) the generated
        # prefixed string and the content string (for typical expressions).
        # while this boolean is certainly available to be ascertained, it
        # makes for unergonomic, noiser and less DRY code.
        #
        # as suchwe effect this behavior: each *formal* member of the below
        # structure is in one of two categories: punctuation-like or word-like.
        #
        # as (in effect) a reduce operation is applied to every *actual*
        # member to build a single aggregate string, the actual member (when
        # true-ish) gets an interceding space added between it and its
        # (if any) previous trueish member IFF they are both word-like
        # according to their formal member.
        #
        # "magic spacing" *is* more limiting than not (because you cannot
        # opt-out of it) with the trade-off that the code is more ergonomic
        # when the user doesn't have to think about these spaces.
        #
        # (this is observed #here.)
        # (this is :#c15n-spot-1)

        pa = Home_::PhraseAssembly.begin_phrase_builder
        mlp = @mutable_line_parts

        pa.add_any_string_as_is mlp.open_string
        pa.add_any_string       mlp.prefixed_string
        pa.add_any_string       mlp.normalized_original_content_string
        pa.add_any_string       mlp.suffixed_string
        pa.add_any_string_as_is mlp.close_string

        pa.flush_to_string
      end

      # ==

      Mutable_Line_Parts___ = ::Struct.new(
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
