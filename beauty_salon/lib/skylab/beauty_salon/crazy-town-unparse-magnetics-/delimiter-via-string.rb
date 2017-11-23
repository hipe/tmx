# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownUnparseMagnetics_::Delimiter_via_String < Common_::Monadic

    # the ways in which you can express delimiters is (for our purposes)
    # unlimited, however they hew to some important patterns.
    #
    # mainly, in implementation of our #spot1.3 optimistic escaping, we
    # need to know exactly what character or characters we need to worry
    # about escaping.

    # -

      def initialize str
        @scn = Home_.lib_.string_scanner.new str
      end

      DO_ = 'do'
      OCTOTHORP_ = '#'
      OPEN_PARENTHESIS_ = '('
      OPEN_SQUARE_BRACKET_ = '['
      PERCENT_ = '%'
      PIPE_ = '|'

      -> do

        THIS_RX___ = ::Regexp.new( <<-O, ::Regexp::EXTENDED )
          [#{

            # the cluster below this comment is for those opening delimiters
            # that are one character wide, and so can be represented in a
            # character class.
            #
            #   - take care if you ever have something that has special
            #     meaning in this context like a DASH_ or a close square bracket.
            #
            #   - the `!` indicate chars that have special meaning in a regex
            #     normally but not in a character class.

          }#{ COLON_ }#{
          }#{ DOUBLE_QUOTE_ }#{
          }#{ FORWARD_SLASH_ }#{
          }#{ OCTOTHORP_ }#{  # !
          }#{ OPEN_PARENTHESIS_ }#{  # !
          }\\#{ OPEN_SQUARE_BRACKET_ }#{  # !
          }#{ PERCENT_ }#{
          }#{ PIPE_ }#{  # !
          }#{ SINGLE_QUOTE_ }#{
          }]#{
            # the cluster below this comment is for those opening delimiters
            # that are more than one characer wide, and so cannot be
            # represented in the above character class.
          }
          |
          #{ DO_ }
        O

        THESE___ = {

          # -- blocks and similar

          DO_ => {
            simply: :DO_AS_IN_DO_END  # never seen..
          },

          OPEN_PARENTHESIS_ => {
            simply: :ARGUMENT_LIST_OR_SIMILAR,  # ..
          },

          # -- args probably

          PIPE_ => {  # #coverpoint3.9
            singleton: true,
          },

          # -- literals with nonstandard delimiters/syntax (see "huggers" below)

          PERCENT_ => {
            method_name: :__percent,
          },

          # -- literals: arrays (and..)

          OPEN_SQUARE_BRACKET_ => {
            simply: :OPEN_SQUARE_BRACKET_FOR_ARRAY_PROBABLY,
          },

          # -- litearals: ideal regexp

          FORWARD_SLASH_ => {
            singleton: true,
          },

          # -- literals: strings and related

          OCTOTHORP_ => {  # (escaping within strings and regexps)
            method_name: :__octothorp,
          },

          DOUBLE_QUOTE_ => {
            singleton: true,
          },

          SINGLE_QUOTE_ => {
            singleton: true,
          },

          # -- literals: ideal symbol

          COLON_ => {  # #coverpoint3.5
            simply: :ideal_literal_symbol,
          }
        }
      end.call

      def execute
        key_s = @scn.scan THIS_RX___
        if ! key_s
          raise COVER_ME, "do this: \"#{ @scn.peek 10 } [..]\""
        end
        @_delimiter_head = key_s.freeze
        @_mode = THESE___.fetch key_s
        m = @_mode[ :method_name ]
        if m
          send m
        else
          __execute_normally
        end
      end

      def __percent

        char = @scn.scan %r([a-z]+)i
        if char
          normal_s = char.downcase
          m = HUGGERS___.fetch normal_s
          if m
            send m
          else
            self._COVER_ME__readme__
            # it's important that you do the escaping right with close
            # supervision. for whatever the kind of thing it is, you have
            # to give it a category name and follow it all the way through.
          end
        else
          _resolve_closing_delimiter_character_and_cetera
          _finish_simply :percenty_custom_delimited_string
        end
      end

      HUGGERS___ = {
        'i' => nil,  # symbols
        'q' => nil,  # single quoted string
        'r' => :__hugged_regexp,  # regex
        's' => nil,  # symbol
        'w' => :__hugged_words,  # words
        'x' => nil,  # shell command
      }

      def __hugged_words
        _resolve_closing_delimiter_character_and_cetera
        _finish_with_two_categories(
          :word_list,
          THIS_IMPORTANT_THING__,
        )
      end

      def __hugged_regexp
        _resolve_closing_delimiter_character_and_cetera
        _finish_with_two_categories(
          :specially_delimited_regexp,
          THIS_IMPORTANT_THING__,
        )
      end

      def _resolve_closing_delimiter_character_and_cetera
        char = @scn.getch
        char || sanity
        complement = PAIRS___[ char ]
        if complement
          @IS_HUGGER = true
          @closing_delimiter_character = complement
        else
          @closing_delimiter_character = char.freeze
        end
      end

      OPEN_CURLY_ = '{'

      PAIRS___ = {
        '(' => ')',
        OPEN_CURLY_ => '}',
        '[' => ']',
        '<' => '>',
      }

      def __octothorp

        char = @scn.peek 1
        OPEN_CURLY_ == char || sanity
        @scn.pos += 1
        _finish_simply :STRING_INTERPOLATION_BEGINNING  # never seen ..
      end

      def __execute_normally
        sym = @_mode[ :simply ]
        if sym
          _finish_simply sym
        elsif @_mode[ :singleton ]
          @delimiter_category_symbol = :singleton_delimiter
          @subcategory_value = :_delimiter_head
          _finish
        end
      end

      def _finish_with_two_categories sub_cat_sym, cat_sym
        @__subcategory_symbol = sub_cat_sym
        @subcategory_value = :__subcategory_symbol
        @delimiter_category_symbol = cat_sym
        _finish
      end

      def _finish_simply sym
        @delimiter_category_symbol = sym
        @subcategory_value = :__nothing
        _finish
      end

      def _finish
        @scn.eos? || sanity
        remove_instance_variable :@_mode
        remove_instance_variable :@scn
        freeze
      end

      def subcategory_value
        send @subcategory_value
      end

      attr_reader(
        :closing_delimiter_character,
        :delimiter_category_symbol,
        :_delimiter_head,
        :__subcategory_symbol,
      )

      def __nothing
        NOTHING_
      end
    # -

    # ==

    module ONE_FOR_HEREDOC ; class << self

      def delimiter_category_symbol
        :pretend_delimiter_for_heredoc
      end

      def subcategory_value
        NOTHING_
      end
    end ; end

    # ==

    THIS_IMPORTANT_THING__ = :percenty_custom_delimited_special
      # currently this is used for cha cha

    # ==
    # ==
  end
end
# #born.
