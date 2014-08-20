module Skylab::Snag

  class Models::ToDo  # see [#003]
    # imagine that parts of this are frozen

    class << self
      def build_enumerator paths, pattern, names
        self::Enumerator__.new paths, pattern, names
      end
    end

    def initialize full_source_line, line_number_string, path, pattern
      @line = full_source_line
      @line_number = line_number_string.to_i
      @line_number_string = line_number_string
      @did_parse = false
      @path = path
      @pathname = nil
      @pattern_s = pattern ; receive_pattern_changed
      @replacement_line = nil
    end

    attr_reader :line_number, :line_number_string, :path

    attr_accessor :replacement_line

    def full_source_line
      @line
    end

    def one_line_summary  # [#it-001] summarization might be nice here
      @did_parse or parse
      if @replacement_line
        _begin = @before_comment_content_range.end +
          Models::Melt.replacement_non_content_width
        @replacement_line[ _begin .. -1 ]
      else
        any_message_body_string
      end
    end

    def pathname
      @pathname.nil? and init_pn
      @pathname
    end
    def init_pn
      @pathname = @path ? ::Pathname.new( @path ) : false
    end

    # ~

    def any_before_comment_content_string
      before_comment_content_range.count.nonzero? and
        @line[ @before_comment_content_range ]
    end

    def any_pre_tag_string  # includes the whitespace
      pre_tag_string_range.count.nonzero? and
        @line[ @pre_tag_string_range ]
    end

    def tag_string
      @line[ tag_string_range ]
    end

    def any_post_tag_string
      post_tag_string_range.count.nonzero? and
        @line[ post_tag_string_range ]
    end

    def any_message_body_string
      message_body_string_range.count.nonzero? and
        @line[ @message_body_string_range ]
    end

  private

    # #note-75

    def before_comment_content_range
      @did_parse or parse
      @before_comment_content_range
    end

    def pre_tag_string_range
      @did_parse or parse
      @pre_tag_string_range
    end

    def tag_string_range
      @did_parse or parse
      @tag_string_range
    end

    def post_tag_string_range
      @did_parse or parse
      @post_tag_string_range
    end

    def message_body_string_range
      @did_parse or parse
      @message_body_string_range
    end

    def parse
      @did_parse = true
      md = @todo_rx.match( @line ) or self._SANITY_RX  # #note-100
      tag_begin = md.begin 0 ; tag_end = md.end 0
      extra_length = if tag_begin.nonzero?
        s = @line[ 0, tag_begin ]
        space_md = SPACE_POUND_SPACE_AT_END_RX__.match s
        space_md ? space_md[ 0 ].length : 0
      else 0 end
      _content_limit = tag_begin - extra_length
      @before_comment_content_range = 0 ... _content_limit
      @pre_tag_string_range = 0 ... tag_begin
      @tag_string_range = tag_begin ... tag_end
      line_length = @line.length
      @post_tag_string_range = tag_end ... line_length  # may be X..X
      @message_body_string_range = if line_length == tag_end
        line_length ... line_length
      else
        _d = ANY_SPACE_AT_BEGINNING_RX__.match( @line, tag_end )[ 0 ].length
        ( tag_end + _d ) ... line_length
      end ; nil
    end

    _OPENING_COMMENT_CHARACTER_RX_ = ::Regexp.escape '#'
    SPACE_POUND_SPACE_AT_END_RX__ =
      / [ \t]+ (?: #{ _OPENING_COMMENT_CHARACTER_RX_ } [ \t]+ )? \z/x
    ANY_SPACE_AT_BEGINNING_RX__ = /\G[ \t]*/


    def receive_pattern_changed
      @todo_rx, @before_rx = Cache__[ @pattern_s ]
    end

    Cache__ = -> do
      bld = -> pattern_s do
        todo_rx = /#{ pattern_s.gsub %r(\\[<>]), '\b' }/  # TERRIBLE
        before_rx = /(?:(?!#{ todo_rx.source }).)*/
        [ todo_rx, before_rx ].freeze
      end
      h = {}
      -> pattern_s do
        h.fetch pattern_s do |_|
          h[ pattern_s ] = bld[ pattern_s ]
        end
      end
    end.call
  end
end
