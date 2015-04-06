module Skylab::Snag

  class Models_::To_Do  # see [#003]

    class << self

      def build * a, & oes_p
        new( a, & oes_p ).valid_result
      end

      def build_scan * a
        self::Collection__.build_scan_via_a a
      end

      def default_pattern_s
        DEFAULT_PATTERN_S__
      end
      DEFAULT_PATTERN_S__ = '[@#]todo\>'.freeze

      private :new
    end  # >>

    Actions = THE_EMPTY_MODULE_

    def initialize a, & oes_p

      @line, @line_number_string, @path, @pattern_s = a

      @line_number = @line_number_string.to_i

      ok = __resolve_regex( & oes_p )

      ok &&= __parse( & oes_p )

      @is_ok = ok
      @mutable = Mutable__.new
      freeze
    end

    Mutable__ = ::Struct.new :replacement_line

    def valid_result
      @is_ok ? self : @is_ok
    end

    attr_reader :line_number, :line_number_string, :path

    def replacement_line
      @mutable.replacement_line
    end

    def replacement_line= x
      @mutable.replacement_line = x
    end

    def full_source_line
      @line
    end

    def one_line_summary  # [#it-001] summarization might be nice here

      if @mutable.replacement_line

        _begin = @before_comment_content_range.end +
          Models::Melt.replacement_non_content_width

        @mutable.replacement_line[ _begin .. -1 ]
      else

        any_message_body_string
      end
    end

    # ~

    def any_before_comment_content_string

      if @before_comment_content_range.count.nonzero?
        @line[ @before_comment_content_range ]
      end
    end

    def any_pre_tag_string  # includes the whitespace

      if @pre_tag_string_range.count.nonzero?
        @line[ @pre_tag_string_range ]
      end
    end

    def tag_string

      @line[ @tag_string_range ]
    end

    def any_post_tag_string

      if @post_tag_string_range.count.nonzero?
        @line[ @post_tag_string_range ]
      end
    end

    def any_message_body_string

      if @message_body_string_range.count.nonzero?
        @line[ @message_body_string_range ]
      end
    end

    def __resolve_regex & oes_p

      @rx = Cache__[ @pattern_s, & oes_p ]
      @rx && ACHIEVED_
    end

    # #note-75

    def __parse & oes_p  # #storypoint-100

      @md = @rx.match @line

      if @md
        __via_matchdata_parse
      else
        oes_p.call :info, :did_not_match do
          __build_did_not_match_event
        end
        NIL_
      end
    end

    def __build_did_not_match_event

      Callback_::Event.inline_neutral_with :did_not_match,
          :line, @line,
          :line_number, @line_number,
          :path, @path,
          :pattern, @pattern_s,
          :rx, @rx do | y, o |

        y << "skipping a line that matched via `grep` but #{
         }did not pass our internal regexp (#{
          }#{ pth o.path }:#{ o.line_number })"

        y << "line: #{ o.line }"
        y << "find pattern: #{ val o.pattern }"
        y << "internal regexp: #{ o.rx.inspect }"
      end
    end

    def __via_matchdata_parse & oes_p

      tag_begin = @md.begin :tag ; tag_end = @md.end :tag
      leader_begin = @md.begin :leader ; leader_end = @md.end :leader
      extra_length = leader_end - leader_begin
      _content_limit = tag_begin - extra_length
      __init_ranges _content_limit, tag_begin, tag_end
    end

    def __init_ranges content_limit, tag_begin, tag_end

      @before_comment_content_range = 0 ... content_limit

      @pre_tag_string_range = 0 ... tag_begin

      @tag_string_range = tag_begin ... tag_end

      line_length = @line.length

      @post_tag_string_range = tag_end ... line_length  # may be X..X

      @message_body_string_range = if line_length == tag_end
        line_length ... line_length
      else
        _d = ANY_SPACE_AT_BEGINNING_RX__.match( @line, tag_end )[ 0 ].length
        ( tag_end + _d ) ... line_length
      end

      ACHIEVED_
    end

    _OPENING_COMMENT_CHARACTER_RX_ = ::Regexp.escape '#'

    SPACE_POUND_SPACE_AT_END_RX__ =
      / [ \t]+ (?: #{ _OPENING_COMMENT_CHARACTER_RX_ } [ \t]+ )? \z/x

    ANY_SPACE_AT_BEGINNING_RX__ = /\G[ \t]*/

    Cache__ = -> do

      h = {}

      -> pattern_s, & oes_p do

        h.fetch pattern_s do |_|

          h[ pattern_s ] = Build_regex_via_grep_pattern___[ pattern_s, & oes_p ]
        end
      end
    end.call

    class Build_regex_via_grep_pattern___  # #note-155

      Callback_::Actor.call self, :properties,
        :pattern_s

      def execute

        @scn = Snag_::Library_::StringScanner.new @pattern_s

        @has_open_boundary = @scn.skip BEGINNING_WORD_BOUNDARY__

        @content_start = @scn.pos

        @content_width = @scn.skip BODY__

        if @content_width
          @has_close_boundary = @scn.skip ENDING_WORD_BOUNDARY__
        end

        if @scn.eos?
          __flush
        else

          rest_s = @scn.rest

          @on_event_selectively.call :error, :expression,
              :unable_to_convert_grep_regex do | y, o |

            y << "misplaced word boundary near #{ ick rest_s }"
          end
        end
      end

      def __flush

        _inner_s = @pattern_s[ @content_start, @content_width ]

        _begin_s = if @has_open_boundary
          BEGINNING_WORD_BOUNDARY_RX_S__
        else
          # COMMON_SANITY_BEGINNING_BOUNDARY_RX_S__  # see below storypoint
          JUST_WHITESPACE_BEGINNING_BOUNDARY_RX_S__
        end

        if @has_close_boundary
          _end_s = ENDING_WORD_BOUNDARY_RX_S__
        end

        /(?<leader>#{ _begin_s })(?<tag>#{ _inner_s }#{ _end_s })/
      end

      # #storypoint-210
      BEGINNING_WORD_BOUNDARY__ = /\\</
      BEGINNING_WORD_BOUNDARY_RX_S__ = '(?<![a-zA-Z0-9.])'
      BODY__ = /(?:(?!\\[<>]).)*/
      COMMON_SANITY_BEGINNING_BOUNDARY_RX_S__ = '(?:^|[ ]+)#[ ]+'
      JUST_WHITESPACE_BEGINNING_BOUNDARY_RX_S__ = '(?:^|[ ]+)'
      ENDING_WORD_BOUNDARY__ = /\\>/
      ENDING_WORD_BOUNDARY_RX_S__ = '(?![a-zA-Z0-9.])'
    end
  end
end
