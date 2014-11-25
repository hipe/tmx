module Skylab::Snag

  class Models::Node::Controller__ < Snag_::Model_::Controller  # see [#045]

    def initialize delegate, _API_client
      @delineated = @do_prepend_open_tag = nil
      @do_prepend_open_tag_ws = true
      @error_count = 0
      @extra_line_header = nil
      @extra_line_a = []
      @first_line_body = @identifier = @line_width = nil
      @max_lines = @message = @is_valid = nil
      super
    end

    attr_reader :identifier, :result_value

    def line_width= b
      @delineated and undelineate ; @line_width = b
    end

    def max_lines= b
      @delineated and undelineate ; @max_lines = b
    end

    def do_prepend_open_tag= b
      @delineated and undelineate ; @do_prepend_open_tag = b
    end

    def do_prepend_open_tag_ws= b
      @delineated and undelineate ; @do_prepend_open_tag_ws = b
    end

    def init_identifier int, node_number_digits
      @identifier and raise say_wont_clobber_identifier
      _integer_s = "%0#{ node_number_digits }d" % int
      @identifier = Models::Identifier.new nil, _integer_s, nil
      nil
    end
    def say_wont_clobber_identifier
      "won't clobber existing identifier: #{ @identifier }"
    end

    def with_flyweight flyweight
      @identifier = flyweight.produce_identifier
      a = [ flyweight.first_line_body ]
      width = extra_lines_header.length
      a.concat( flyweight.extra_line_a.map do |s|
        if @extra_line_header == s[ 0, width ]
          s[ @width .. -1 ]
        else
          s.strip
        end
      end )
      @message = a * SPACE_
      self
    end
  private
    def extra_lines_header
      @extra_lines_header ||= bld_xtra_lines_header
    end

    def bld_xtra_lines_header
      # "[#867] #open ".length
      _open_tag = Models::Tag.canonical_tags.open_tag
      _d = Models::Manifest.header_width + _open_tag.render.length + 1
      SPACE_ * _d
    end
  public

    def close  # #narration-60
      lstnr = @delegate
      p = lstnr.method :receive_info_event
      delegate_ = Snag_::Model_::Info_Error_Delegate.new p, p
      rm_x = remove_tag :open, :delegate, delegate_
      ad_x = add_tag :done, :prepend, :delegate, delegate_
      if UNABLE_ == rm_x || UNABLE_ == ad_x
        UNABLE_
      else
        rm_x || ad_x
      end
    end
  public

    def extra_line_a
      @delineated or delineate
      @extra_line_a.dup
    end

    def extra_lines_count
      @delineated or delineate
      @extra_line_a.length
    end

    def first_line_body
      @delineated or delineate
      @first_line_body
    end

    def message= msg
      ok = Models::Message.normalize msg, method( :receive_error_string )
      if ok
        undelineate
        @message = ok
      end
      msg
    end

    def is_valid
      @is_valid.nil? and determine_validity
      @is_valid
    end
  private
    def determine_validity
      if @error_count.nonzero?
        @is_valid = false
      else
        determine_validity_when_error_count_is_zero
      end ; nil
    end
    def determine_validity_when_error_count_is_zero
      if @delineated || delineate
        determine_validity_when_delineated
      else
        @is_valid = false
      end ; nil
    end
    def determine_validity_when_delineated
      if @first_line_body
        @is_valid = true
      else
        send_error_string "node must have a message body."
        @is_valid = false
      end ; nil
    end
  public

    # ~ tags

    def add_tag tag_ref, * x_a
      tags_controller.add_tag_using_iambic tag_ref, x_a
    end

    def remove_tag tag_ref, * x_a
      tags_controller.remove_tag_using_iambic tag_ref, x_a
    end

    def tags_controller
      @tc ||= tags.build_controller tags_delegate
    end

    def tags
      @tags ||= Models::Tag::Collection__.new @message, @identifier
    end
  private

    def tags_delegate
      @tl ||= bld_tags_delegate
    end

    def bld_tags_delegate
      lstnr = @delegate
      Callback_::Ordered_Dictionary.inline.with( :suffix, nil ).inline(
        :error_event, lstnr.method( :receive_error_event ),
        :info_event, lstnr.method( :receive_info_event ),
        :change_body_string, method( :receive_change_body_string ) )
    end

    def receive_change_body_string s
      @message = s ; undelineate
      @tc.set_body_s s ; nil
    end

    def delineate
      @delineated = true
      p = -> s do
        @first_line_body = s
        p = -> s_ { @extra_line_a.push s_ }
      end
      @valid = Delineate_message__[
        extra_lines_header, line_width, @delegate,
        max_lines, @message,
        @do_prepend_open_tag, @do_prepend_open_tag_ws,
        -> s { p[ s ] } ]
    end

    def undelineate
      @delineated = nil
      @extra_line_a.clear
      @first_line_body = nil
      @valid = nil
    end

    # ~ used by above

    def line_width
      @line_width || Models::Manifest.line_width  # don't memoize it
    end
    protected :line_width  # #protected-not-private

    def max_lines
      @max_lines ||= Models::Node.max_lines_per_node
    end

    # ~

    def receive_error_string s
      @error_count += 1
      x = send_error_string s
      @result_value = x || UNABLE_  # digraphs will never result in false
    end

    def send_error_string s
      @delegate.receive_error_string s
    end

    def send_info_string s
      @delegate.receive_info_string s
    end

    class Delineate_message__

      Snag_::Model_::Actor[ self,
        :properties, :extra_lines_header,
        :line_width, :delegate,
        :max_lines, :message_s,
        :do_prepend_open_tag, :do_prepend_open_tag_ws,
        :y_p ]

      def execute
        prepare
        work
      end

    private

      def prepare
        @curr_width = Models::Manifest.header_width
        @line_a = [] ; @line_head = 0
        @open_tag_s = Models::Tag.canonical_tags.open_tag.render
        @subsequent_curr_width = @extra_lines_header ?
          @extra_lines_header.length : 0
        @line_width >= @curr_width or self._SANITY
        @line_width > @subsequent_curr_width or self._SANITY
        @scn = Snag_::Library_::StringScanner.new bld_stream_string ; nil
      end

      def bld_stream_string
        a = []
        if @do_prepend_open_tag
          a.push @open_tag_s
        elsif @do_prepend_open_tag_ws
          _is = @message_s && @open_tag_s == @message_s[ 0, @open_tag_s.length ]
          _is or a.push( SPACE_ * @open_tag_s.length )  # [#021] indent per this
        end
        @message_s and a.push @message_s
        a.join SPACE_
      end

      def work
        ok = OK__
        until @scn.eos?
          ok = scan_one_word
          ok or break
        end
        ok && flush_words
      end

      def scan_one_word
        @white_head = @scn.pos
        @ws = @scn.skip SP__
        @content_head = @scn.pos
        @ct = @scn.skip CON__
        if @ct
          when_word_content
        else
          @ws or self._IMPOSSSIBLE
        end
      end
      SP__ = /[ \t]+/ ; CON__ = /[^ \t]+/

      def when_word_content
        if @curr_width + ( @scn.pos - @line_head ) > @line_width
          when_reached_line_end
        else
          OK__  # keep scanning, you are not over the line yet
        end
      end

      def when_reached_line_end
        if @line_head == @white_head
          @content_head = @white_head =
            @line_head + ( @line_width - @curr_width )
        end
        ok = push @scn.string[ @line_head ... @white_head ]
        if ok
          @curr_width = @subsequent_curr_width
          @line_head = @content_head
        end
        ok
      end

      def flush_words
        ok = OK__
        if @line_head < ( @scn.pos - 1 )
          ok = finish_scan
        end
        if ok
          @line_a.each do |line|
            @y_p[ line.freeze ]
          end
          @line_a = nil
        end
        ok
      end

      def finish_scan
        @scn.pos = @line_head
        rx = /.{1,#{ @line_width - @subsequent_curr_width }}/
        str = @scn.scan rx
        begin
          ok = push str
          ok or break
          str = @scn.scan rx
        end while str
        if ok
          @scn.eos? or self._SANITY
        end
        ok
      end

      def push line
        if @line_a.length < @max_lines
          if @line_a.length.nonzero? && @extra_lines_header
            line = "#{ @extra_lines_header }#{ line }"
          end
          @line_a.push line
          OK__
        else
          send_line_length_exceeded_event line
          UNABLE_
        end
      end

      def send_line_length_exceeded_event line
        send_error_event :message_line_limit_exceeded,
          :max_lines, @max_lines, :message_s, @message_s,
          :near_s, First_wrd__[ line ] do |y, o|

          y << "your message would exceed the #{ o.max_lines } line #{
            }limit (near #{ ick o.near_s })"
        end
      end

      First_wrd__ = -> str do
        /\A\W*\w{0,8}/.match( str )[0]
      end

      OK__ = true
    end
  end
end
