module Skylab::BeautySalon

  class Models_::Deliterate < Home_.lib_.brazen::Model

    Actions = ::Module.new

    Brazen_ = Home_.lib_.brazen

    class Actions::Ping < Brazen_::Action  # :+#stowaway (while it works)

      @is_promoted = true

      def produce_result
        @on_event_selectively.call :info, :expression, :ping do | y |
          y << "hello from beauty salon."
        end
        :hello_from_beauty_salon
      end
    end

    class Actions::Deliterate < Brazen_::Action

      @is_promoted = true

      Brazen_::Modelesque.entity self

      edit_entity_class(

        :required, :property, :comment_line_downstream,
        :required, :property, :code_line_downstream,

        :required, :property, :line_upstream,

        :required,
        :integer_greater_than_or_equal_to, 1,
        :property, :from_line,

        :required,
        :integer,
        :ad_hoc_normalizer, -> qkn, & oes_p do

          Home_.lib_.basic::Range.normalize_qualified_knownness(
            qkn, :is, -1, :or, :begin, 1,
            & oes_p )
        end,

        :property, :to_line,

        :desc, -> y do
          # <- 2
      _big_string =  <<-O.gsub %r(^ {8}), EMPTY_S_
        from line <from-line> to line <to-line> of file <file>, use a
        simple character-scanning ** HACK ** to partition each line of
        code into comment and not-comment.

        to stdout each code-line will be output with any trailing comment
        removed. for those lines that had a comment, these lines will be
        stripped of any would-be trailing whitespace.

        the comments that are stripped out of these lines are buffered
        until something resembling a paragraph break occurs (e.g a line
        with no comment, or when the end of relevant input is reached).
        at such times this buffer is flushed to stderr, resulting in one
        (potentially "long") paragraph-as-line at a time progressively as
        they are "finished".

        any comment lines that are output never have leading or trailing
        whitespace, nor will they ever be blank lines.

        some code lines that have a comment may be empty of content after
        the comment has been partitioned out. in a contiguous span of such
        lines, only the first one will result in the outputtal of a blank
        code line. i.e, this utility will not add more blank lines to your
        code than there were already, nor will it take any out that were
        there to begin with. however, your SLOC will reduce for those lines
        of code that have nothing but comments in them.

        this has no language-aware facilities at all, so false
        interpretations can occur. the algorithm is the simplest
        it could possibly be: it matches the first '#' it sees in the line
        and interprets that to be the beginning of a comment, with no
        regard for its "context".
      O

      scn = Home_.lib_.basic::String.line_stream _big_string
      while (( s = scn.gets ))
        y << s
      end
      NIL_
    # -> 2
        end,
      )
      # <- 2

    def produce_result

      via_properties_init_ivars
      ok = normalize_range
      ok && prepare
      ok && __work
    end

    def normalize_range           # for example,
                                  # you could deliterate
      if @to_line < @from_line    # these lines.

        __maybe_express_upside_down_range

        UNABLE_
      else
        ACHIEVED_
      end
    end

    def __maybe_express_upside_down_range

      foz = formal_properties
      fl = foz.fetch :from_line
      tl = foz.fetch :to_line
      d = @from_line
      d_ = @to_line

      maybe_send_event :error, :expression, :upside_down_range do | y |

        y << "#{ par tl } (#{ val d_ }) #{
          }cannot be less than #{ par fl } (#{ val d })"
      end
    end

    def prepare
      @blank_count = 0
      @line_count = 0
      @paragraph = nil
      to_line_d = remove_instance_variable :@to_line
      @do_process_next_line_p = if -1 == to_line_d
        NILADIC_TRUTH_
      else
        -> do
          @line_count < to_line_d
        end
      end
      NIL_
    end

    NILADIC_TRUTH_ = -> { true }

    def __work
      skip_lines
      while @line = @line_upstream.gets
        ok = @do_process_next_line_p[]
        if ok
          @line_count += 1
          process_line
        else
          break
        end
      end
      @paragraph and flush
      ACHIEVED_
    end

    def skip_lines
      if 1 < @from_line
        stop_at = @from_line - 1
        while @line_upstream.gets
          @line_count += 1
          if stop_at == @line_count
            break
          end
        end
      end
      NIL_
    end

    def process_line
      @pos = @line.index COMMENT_CHARACTER__
      if @pos
        process_comment_line
      else
        process_code_line
      end
    end

    COMMENT_CHARACTER__ = '#'.freeze

    def process_code_line
      @paragraph and flush
      @blank_count = 0
      send_code_line @line
    end

    def process_comment_line
      receive_comment_string @line[ @pos .. -1 ]
      code_string = @line[ 0, @pos ]
      code_string.sub! TRAILING_WS_RX__, EMPTY_S_
      if code_string.length.zero?
        was_zero = @blank_count.zero?
        @blank_count += 1
        if was_zero
          send_code_line_via_string code_string
        end
      else
        @blank_count = 0
        send_code_line_via_string code_string
      end
      NIL_
    end

    TRAILING_WS_RX__ = /[\t ]+\z/

    def send_code_line_via_string string
      send_code_line "#{ string }#{ NEWLINE_ }"
    end

    def send_code_line line
      @code_line_downstream << line
      NIL_
    end

    def receive_comment_string string
      cs = Models_::Comment_String.new string, @pos
      if cs.is_effectively_empty
        @paragraph and flush
      else
        @paragraph ||= Models_::Paragraph.new
        @paragraph.add_comment_string cs
      end
      NIL_
    end

    def flush

      line = @paragraph.produce_line
      if line
        @comment_line_downstream << line  # client can add newlines herself.
      end
      @paragraph = nil
    end

    Models_ = ::Module.new

    class Models_::Comment_String

      def initialize str, pos
        md = TRIM_RX__.match str
        @content_s = md[ 1 ]
      end

      TRIM_RX__ = /\A \# [ \t]*  ( | [^ \t]+ (?: [ \t]+[^ \t]+ )*  )  [ \t]* \r?\n  \z/x

      def content_string
        @content_s
      end

      def is_effectively_empty
        @content_s.length.zero?
      end
    end

    class Models_::Paragraph

      def initialize
        @a = []
      end

      def add_comment_string cs
        @a.push cs ; nil
      end

      def produce_line
        scn = Callback_::Stream.via_nonsparse_array @a
        cs = scn.gets
        if cs
          s = cs.content_string
          a = [ s ]
          was_connector = CONNECTOR_RX__ =~ s
        end
        while cs = scn.gets
          s = cs.content_string
          if ! was_connector
            a.push SPACE_
          end
          a.push s
          was_connector = CONNECTOR_RX__ =~ s
        end
        if a
          ( a * EMPTY_S_ )
        end
      end
    end

      CONNECTOR_RX__ = /-\z/

      CODE_LINE_PREFIX__ = 'code line:     '
      COMMENT_LINE_PREFIX__ = 'comment line:  '
      SKIP_LINE_PREFIX__ = 'skipping line: '

    end
  end
end
# :+#tombstone: interactive mode
