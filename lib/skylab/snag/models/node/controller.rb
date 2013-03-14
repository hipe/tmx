module Skylab::Snag

  class Models::Node::Controller

    include Snag::Core::SubClient::InstanceMethods

    def add_tag tag_ref, do_append
      tag( ( do_append ? :append : :prepend ), tag_ref, -> e { error e } )
    end

    def build_identifier! int, node_number_digits
      fail "won't clobber existing identifier" if @identifier
      integer_string = "%0#{ node_number_digits }d" % int
      @identifier = Models::Identifier.new nil, integer_string, integer_string
      nil
    end

    def close
      res = nil
      begin
        redundant = -> e { info e ; nil }
        a = tag :remove,  :open, redundant
        b = tag :prepend, :done, redundant
        res = if false == a || false == b
          # an error for one is an error for all, don't rewrite file
          false
        else
          # two nils means it was fully redundant, do not rewrite file
          # else at least one of them was trueish, rewrite file.
          a || b
        end
      end while nil
      res
    end

    attr_reader :date_string

    def date_string= string
      ok = Models::Date.normalize string,
        -> e { error e }, -> e { info e }
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

    def extra_lines
      @delineated or delineate
      @extra_lines.dup
    end

    def extra_lines_count
      @delineated or delineate
      @extra_lines.length
    end

    def first_line_body
      @delineated or delineate
      @first_line_body
    end

    attr_reader :identifier

    def message= msg
      ok = Models::Message.normalize msg, -> e { error e }, -> e { info e }
      if ok
        undelineate
        @message = ok
      end
      msg
    end

    def remove_tag tag_ref
      tag :remove, tag_ref, -> e { error e }
    end

    def tags
      @tags ||= Models::Tag::Collection.new @message # asking for trouble
    end

    def valid
      if @valid.nil? # iff not, we've already done this
        begin
          break( @valid = false ) if error_count > 0 # iff errors emitted
          @delineated or delineate or break( @valid = false )
          if ! @first_line_body
            error "node must have a message body."
            break( @valid = false )
          end
          @valid = true
        end while nil
      end
      @valid
    end

  protected

    def initialize request_client, flyweight=nil
      super request_client
      @date_string = nil
      @delineated = nil
      @do_prepend_open_tag = nil
      @do_prepend_open_tag_ws = true
      @extra_line_header = nil
      @extra_lines = []
      @first_line_body = nil
      @identifier = nil
      @line_width = nil
      @max_lines = nil
      @message = nil
      absorb_flyweight!( flyweight ) if flyweight
      nil
    end

    def absorb_flyweight! flyweight
      # (this was written expecting it's called only from a constructor)
      @delineated and fail 'test me'
      @identifier = flyweight.build_identifier
      reduce = [ flyweight.first_line_body ]
      reduce.concat( flyweight.extra_lines.map do |el|
        if 0 == el.index( extra_lines_header )
          use = el[ extra_lines_header.length .. -1 ]
        else
          use = el.strip # sketchy but not really -- whatever
        end
        use
      end )
      @message = reduce.join ' '
      nil
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

          open_tag = Models::Tag.canonical[ :open ]
          scn = Snag::Services::StringScanner.new -> do
            parts = [ ]
            if @do_prepend_open_tag
              parts.push open_tag
            elsif @do_prepend_open_tag_ws
              if ! ( @message && 0 == @message.index( open_tag.render ) )
                parts.push( ' ' * open_tag.render.length ) # [#sg-021]
              end
            end
            parts.push @message if @message
            parts.push @date_string if @date_string
            parts.join ' '
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
              error "your message would exceed the #{ max_lines } line #{
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
          @extra_lines.concat lines.map(&:freeze)
          res = @delineated = true
        end while nil
        res
      end
    end

    def extra_lines_header
      @extra_lines_header ||= begin
        # "[#867] #open "
        x = Models::Manifest.header_width +
          Models::Tag.canonical[ :open ].to_s.length + 1
        ' ' * x
      end
    end

    def line_width
      @line_width || Models::Manifest.line_width  # don't memoize it
    end

    def max_lines
      @max_lines ||= Models::Node.max_lines_per_node
    end

    tag_parse_args = -> operation do
      case operation
      when :prepend ; do_add = true ; do_append = false
      when :append  ; do_add = true ; do_append = true
      when :remove  ; do_add = false
      else raise ::ArgumentError.new "no"
      end
      [ do_add, do_append ]
    end

    define_method :tag do |operation, tag_ref, redundant|
      error, info = method( :error ), method( :info )
      do_add, do_append = tag_parse_args[ operation ] ; operation = nil
      begin
        res = Models::Tag.normalize( tag_ref, error, info ) or break
        tag_body = res
        found = tags.detect { |tg| tg.normalized_name == tag_body }
        rdn = nil ; redundnt = -> msg { rdn = true ; redundant[ msg ] }
        res = if do_add
          if found
            redundnt[ "#{ val @identifier } is already tagged #{
              }with #{ val found }" ]
          else
            tags.add! tag_body, do_append, error, info
          end
        elsif found
          tags.rm! found, error, info
        else
          redundnt[ "#{ val @identifier } is not tagged with #{
            }#{ ick Models::Tag.render( tag_body ) }" ]
        end
        rdn and break
        undelineate               # here after above success. caveat err cnt
        res = valid               # it might be too long now
      end while nil
      res
    end

    def undelineate
      @delineated = nil
      @extra_lines.clear
      @first_line_body = nil
      @valid = nil
    end
  end
end
