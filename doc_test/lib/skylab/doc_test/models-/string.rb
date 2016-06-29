module Skylab::DocTest

  module Models_::String

    # mainly parse quoted string literals and unescape them.

    class << self

      def unescape_quoted_literal_anchored_at_head s
        # assume exactly one leading tab or space character
        Unescape_head_anchored_quoted_string_literal___[ s ]
      end

      def match_quoted_string_literal s
        EXACT_MATCH_RX___.match s
      end

      def unescape_quoted_string_literal_matchdata md
        Unescape_matchdata__[ md ]
      end

      def quoted_string_regex_part
        QUOTED_STRING_REGEX_PART___
      end
    end  # >>

    Unescape_head_anchored_quoted_string_literal___ = -> s do

      Unescape_matchdata__[ SOFT_MATCH_RX___.match(s) ]
    end

    Unescaping_Schema__ = ::Struct.new :rx, :escape_map_by

    dquote = '"'
    squote = "'"
    bslash = '\\'

    DOUBLE_UNESCAPING_SCHEMA___ = Unescaping_Schema__.new(
      / \\ (?<special_char> . ) /x,
      Lazy_.call do
        {
          dquote => dquote,
          bslash => bslash,
        }
      end
    )

    SINGLE_UNESCAPING_SCHEMA___ = Unescaping_Schema__.new(
      / \\ (?<special_char> . ) /x,  # tighten this
      Lazy_.call do
        {
          squote => squote,
          bslash => bslash,
        }
      end
    )

    Unescape_matchdata__ = -> md do

      s = md[ :double_quoted_bytes ]
      if s
        schema = DOUBLE_UNESCAPING_SCHEMA___
      else
        s = md[ :single_quoted_bytes ]
        schema = SINGLE_UNESCAPING_SCHEMA___
      end

      s.gsub schema.rx do

        # (once you get inside here, it means that yes the string
        #  probably had ostensible escape sequences in it.)

        _char = $~[ :special_char ]  # a string one character in length
        _map = schema.escape_map_by[]
        _map.fetch _char
      end
    end

    # --

    quoted_string_part = %q<
      (?:
        " (?<double_quoted_bytes> (?: [^\\\\"] | \\\\. )* ) " |
        ' (?<single_quoted_bytes> (?: [^\\\\'] | \\\\. )* ) ' |
      )
    >

    # (#coverpoint4-3: we need those four (or three :/) backslashes.)

    QUOTED_STRING_REGEX_PART___ = quoted_string_part

    SOFT_MATCH_RX___ = /\A[ \t]#{ quoted_string_part }/x

    EXACT_MATCH_RX___ = /\A#{ quoted_string_part }\z/x
  end
end
# #history: broke out of output adapters quickie test document parser
