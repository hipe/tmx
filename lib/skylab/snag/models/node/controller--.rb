module Skylab::Snag

  class Models::Node::Controller__ < Snag_::Model_::Controller  # see [#045]

    def initialize listener, _API_client
      @date_string = @delineated = @do_prepend_open_tag = nil
      @do_prepend_open_tag_ws = true
      @error_count = 0
      @extra_line_header = nil
      @extra_line_a = []
      @first_line_body = @identifier = @line_width = nil
      @max_lines = @message = @is_valid = nil
      super
    end

    attr_reader :result_value

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
      lstnr = @listener
      p = lstnr.method :receive_info_event
      listener_ = Snag_::Model_::Info_Error_Listener.new p, p
      rm_x = remove_tag :open, :listener, listener_
      ad_x = add_tag :done, :prepend, :listener, listener_
      if UNABLE_ == rm_x || UNABLE_ == ad_x
        UNABLE_
      else
        rm_x || ad_x
      end
    end
  public

    attr_reader :date_string

    def date_string= string
      ok = Models::Date.normalize string, @listener
      if ok
        undelineate
        @date_string = ok
      end
      string
    end

    def do_prepend_open_tag= b
      undelineate
      @do_prepend_open_tag = b
    end

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

    attr_reader :identifier

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
      @tc ||= tags.build_controller tags_listener
    end

    def tags
      @tags ||= Models::Tag::Collection__.new @message, @identifier
    end
  private

    def tags_listener
      @tl ||= bld_tags_listener
    end

    def bld_tags_listener
      lstnr = @listener
      Callback_::Ordered_Dictionary.inline.with( :suffix, nil ).inline(
        :error_event, lstnr.method( :receive_error_event ),
        :info_event, lstnr.method( :receive_info_event ),
        :change_body_string, method( :receive_change_body_string ) )
    end

    def receive_change_body_string s
      @message = s ; undelineate
      @tc.set_body_s s ; nil
    end

    first_wrd = -> str do
      /\A\W*\w{0,8}/.match( str )[0]
    end

    define_method :delineate do
      if ! @delineated
        res = nil
        begin
          curr_width = Models::Manifest.header_width
          subsequent_curr_width = extra_lines_header.length
          ( line_width = self.line_width ) >= curr_width or fail 'sanity'
          line_width > subsequent_curr_width or fail 'sanity'
          lines = []
          ok = true

          open_tag = Models::Tag.canonical_tags.open_tag
          scn = Snag_::Library_::StringScanner.new -> do
            parts = [ ]
            if @do_prepend_open_tag
              parts.push open_tag
            elsif @do_prepend_open_tag_ws
              if ! ( @message && 0 == @message.index( open_tag.render ) )
                parts.push( SPACE_ * open_tag.render.length ) # [#sg-021]
              end
            end
            parts.push @message if @message
            parts.push @date_string if @date_string
            parts.join SPACE_
          end.call # '' might be ok

          failure = -> msg do
            ok = false
            fail "sanity - expecting #{ msg } in string #{
            }near #{ scn.peek( 8 ).inspect }"
          end

          push = -> line do
            if lines.length < max_lines
              if lines.length.nonzero?
                line = "#{ extra_lines_header }#{ line }"
              end
              lines.push line
              true
            else
              send_error_string "your message would exceed the #{
               }#{ max_lines } line #{
                }limit (near #{ first_wrd[ line ].inspect })"
              @delineated = true               # avoid hiccups .. hm
              ok = false                       # also result
            end
          end

          line_head = 0                        # ~ climax ~
          until scn.eos?
            white_head = scn.pos
            ws = scn.skip( /[ \t]+/ )          # let user add leading ws
            content_head = scn.pos             # but at beg of line 2 skip ws
            ct = scn.skip( /[^ \t]+/ )
            if ct
              if curr_width + ( scn.pos - line_head ) > line_width
                if line_head == white_head
                  content_head = white_head =
                    line_head + ( line_width - curr_width )
                end
                push[ scn.string[ line_head .. white_head - 1 ] ] or break
                curr_width = subsequent_curr_width
                line_head = content_head
              end
            elsif ! ws
              break( failure[ 'content' ] )
            end
          end
          ok or break
          if line_head < ( scn.pos - 1 )
            scn.pos = line_head
            rx = /.{1,#{ line_width - subsequent_curr_width }}/
            str = scn.scan rx
            begin
              push[ str ] or break
              str = scn.scan rx
            end while str
            ok or break
            scn.eos? or fail 'sanity - parsing hack failed'
          end
                                               # ~ dénouement ~
          if lines.length.nonzero?
            @first_line_body = lines.shift.freeze
          end
          @extra_line_a.concat lines.map(&:freeze)
          res = @delineated = true
        end while nil
        res
      end
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
      @listener.receive_error_string s
    end

    def send_info_string s
      @listener.receive_info_string s
    end
  end
end
