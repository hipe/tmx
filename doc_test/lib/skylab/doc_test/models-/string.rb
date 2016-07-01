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
        QUOTED_STRING_REGEX_PART__
      end
    end  # >>

    Unescape_head_anchored_quoted_string_literal___ = -> s do

      Unescape_matchdata__[ SOFT_MATCH_RX___.match(s) ]
    end

    # (#coverpoint4-3 moved to [ba]!)

    qsll = Home_.lib_.basic::String.quoted_string_literal_library

    Unescape_matchdata__ = qsll::Unescape_matchdata

    quoted_string_part = qsll::QUOTED_STRING_REGEX_PART

    QUOTED_STRING_REGEX_PART__ = quoted_string_part

    SOFT_MATCH_RX___ = /\A[ \t]#{ quoted_string_part }/x

    EXACT_MATCH_RX___ = /\A#{ quoted_string_part }\z/x

  end
end
# #pending-rename: probably etc because of [ta] needing this
# #history: broke out of output adapters quickie test document parser
