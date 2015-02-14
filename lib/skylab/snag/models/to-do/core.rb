module Skylab::Snag

  class Models::ToDo  # see [#003]

    class << self

      def build *a
        new( a ).valid_result
      end

      def build_scan * a
        self::Collection__.build_scan_via_a a
      end

      def default_pattern_s
        DEFAULT_PATTERN_S__
      end
      DEFAULT_PATTERN_S__ = '[@#]todo\>'.freeze

      private :new
    end

    Snag_::Model_::Actor[ self ]

    def initialize a
      @line, @line_number_string, @path, @pattern_s, @delegate = a
      @line_number = @line_number_string.to_i
      @pathname = ::Pathname.new @path
      ok = resolve_regex
      ok &&= parse
      @is_ok = ok
      @mutable = Mutable__.new
      freeze
    end

    Mutable__ = ::Struct.new :replacement_line

    def valid_result
      @is_ok ? self : @is_ok
    end

    attr_reader :line_number, :line_number_string, :path, :pathname

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
      @before_comment_content_range.count.nonzero? and
        @line[ @before_comment_content_range ]
    end

    def any_pre_tag_string  # includes the whitespace
      @pre_tag_string_range.count.nonzero? and
        @line[ @pre_tag_string_range ]
    end

    def tag_string
      @line[ @tag_string_range ]
    end

    def any_post_tag_string
      @post_tag_string_range.count.nonzero? and
        @line[ @post_tag_string_range ]
    end

    def any_message_body_string
      @message_body_string_range.count.nonzero? and
        @line[ @message_body_string_range ]
    end

  private

    def resolve_regex
      @rx = Cache__[ @pattern_s, @delegate ]
      @rx && ACHIEVED_
    end

    # #note-75

    def parse  # #storypoint-100
      @md = @rx.match @line
      if @md
        parse_when_matched
      else
        send_did_not_match_event
      end
    end

    def send_did_not_match_event

      send_info_event :did_not_match, :line, @line, :line_number, @line_number,
        :pn, pathname, :pattern, @pattern_s, :rx, @rx do |y, o|

        y << "skipping a line that matched via `grep` but #{
         }did not pass our internal regexp (#{
          }#{ pth o.pn }:#{ o.line_number })"
        y << "line: #{ o.line }"
        y << "find pattern: #{ val o.pattern }"
        y << "internal regexp: #{ o.rx.inspect }"
      end
    end

    def parse_when_matched
      tag_begin = @md.begin :tag ; tag_end = @md.end :tag
      leader_begin = @md.begin :leader ; leader_end = @md.end :leader
      extra_length = leader_end - leader_begin
      _content_limit = tag_begin - extra_length
      build_ranges _content_limit, tag_begin, tag_end
    end

    def build_ranges content_limit, tag_begin, tag_end
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
      -> pattern_s, delegate do
        h.fetch pattern_s do |_|
          h[ pattern_s ] = Build_regex__[ pattern_s, delegate ]
        end
      end
    end.call

    class Build_regex__  # #note-155

      Snag_::Model_::Actor[ self,
        :properties, :pattern_s, :delegate ]

      def execute
        @scn = Snag_::Library_::StringScanner.new @pattern_s
        @has_open_boundary = @scn.skip BEGINNING_WORD_BOUNDARY__
        @content_start = @scn.pos
        @content_width = @scn.skip BODY__
        if @content_width
          @has_close_boundary = @scn.skip ENDING_WORD_BOUNDARY__
        end
        if @scn.eos?
          flush
        else
          send_unable_to_convert_grep_regex_event
          UNABLE_
        end
      end

    private

      def send_unable_to_convert_grep_regex_event
        send_error_event :unable_to_convert_grep_regex,
            :rest_s, @scn.rest do |y, o|
          y << "misplaced word boundary near #{ ick o.rest_s }"
        end
      end

      def flush
        inner_s = @pattern_s[ @content_start, @content_width ]
        begin_s = if @has_open_boundary
          BEGINNING_WORD_BOUNDARY_RX_S__
        else
          # COMMON_SANITY_BEGINNING_BOUNDARY_RX_S__  # see below storypoint
          JUST_WHITESPACE_BEGINNING_BOUNDARY_RX_S__
        end
        if @has_close_boundary
          end_s = ENDING_WORD_BOUNDARY_RX_S__
        end
        /(?<leader>#{ begin_s })(?<tag>#{ inner_s }#{ end_s })/
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

    Event_ = Snag_::Model_::Event
  end
end
