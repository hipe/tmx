module Skylab::BeautySalon

  class Models_::Deliterate < BS_::Lib_::Brazen[].model.action_class

    Brazen_ = BS_::Lib_::Brazen[]

    def write_options o

      o.separator EMPTY_S_

      o.separator 'description:'

      o.separator <<-O.gsub %r(^ {8}), EMPTY_S_

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

        if <file> is not provided <stdin> is used, regarless of whether or
        not it is interactive.

        this has no language-aware facilities at all, so false
        interpretations can occur. the algorithm is the simplest
        it could possibly be: it matches the first '#' it sees in the line
        and interprets that to be the beginning of a comment, with no
        regard for its "context".

      O
    end

    Brazen_.model_entity self, -> do

      o :properties,
          :input_path,
          :input_stream,
          :from_line,
          :to_line,
          :comment_line_yieldee,
          :code_line_yieldee

    end

    Brazen_.event.sender self

    def produce_any_result
      init_ivars
      ok = normalize_line_ranges
      ok &&= resolve_input_stream
      ok and work
    end

  private

    def init_ivars
      via_properties_init_ivars
      @error_p = -> ev do
        receive_event ev
        UNABLE_
      end ; nil
    end

    def normalize_line_ranges
      @range = bound_properties.at :from_line, :to_line
      @range.length.times do |d|
        bp = @range.fetch( d ).dup  # we will mutate it
        @range[ d ] = bp
        instance_variable_set bp.name.as_ivar, bp  # overwrite original x
      end
      ok = normalize_as_integers
      ok && normalize_range
    end

    def normalize_as_integers
      ok = true
      integer = Brazen_.model_entity.normalizers.numeric.instance
      @range.each do |bp|
        d = integer.via_two bp, @error_p
        if d
          bp.value_x = d
        else
          ok = d
        end
      end
      ok
    end

    def normalize_range
      okay = true
      ok = BS_::Lib_::Range_lib[].normalize @from_line, :begin, 1, @error_p
      ok or okay = false
      ok = BS_::Lib_::Range_lib[].normalize @to_line, :is, -1, :or, :begin, 1, @error_p
      ok or okay = false
      okay
    end

    def resolve_input_stream
      if @input_stream
        ACHEIVED_
      else
        via_input_path_resolve_input_stream
      end
    end

    def via_input_path_resolve_input_stream
      @input_stream = ::File.open @input_path, READ_MODE_
      @input_stream && ACHEIVED_
    rescue ::Errno::ENOENT => e
      _ev = Brazen_.event.wrap.exception :exception, e,
        :path_hack, :terminal_channel_i, :resource_not_found
      receive_event _ev
      UNABLE_
    end

    def work
      prepare
      if @input_stream.tty?
        work_when_interactive
      else
        work_when_non_interactive
      end
    end

    def prepare
      @blank_count = 0
      @from_line = @from_line.value_x
      @line_count = 0
      @paragraph = nil
      to_line_d = @to_line.value_x
      @to_line = nil
      @do_process_next_line_p = if -1 == to_line_d
        NILADIC_TRUTH_
      else
        -> do
          @line_count < to_line_d
        end
      end ; nil
    end

    NILADIC_TRUTH_ = -> { true }

    def work_when_interactive
      @is_interactive = true
      @y = @comment_line_yieldee
      @y << "interactive mode started. enter lines. ^C to interrupt, ^D when done"
      process_lines
    end

    def work_when_non_interactive
      @is_interactive = false
      process_lines
    end

    def process_lines
      skip_lines
      while @line = @input_stream.gets
        ok = @do_process_next_line_p[]
        if ok
          @line_count += 1
          process_line
        else
          break
        end
      end
      @paragraph and flush
      nil
    end

    def skip_lines
      if 1 < @from_line
        stop_at = @from_line - 1
        while skipped = @input_stream.gets
          if @is_interactive
            @y << "#{ SKIP_LINE_PREFIX__ }#{ skipped }"
          end
          @line_count += 1
          if stop_at == @line_count
            break
          end
        end
      end ; nil
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
      end ; nil
    end

    TRAILING_WS_RX__ = /[\t ]+\z/

    def send_code_line_via_string string
      send_code_line "#{ string }#{ NEWLINE_ }"
    end

    def send_code_line line
      if @is_interactive
        @code_line_yieldee << "#{ CODE_LINE_PREFIX__ }#{ line }"
      else
        @code_line_yieldee << line
      end ; nil
    end

    NEWLINE_ = "\n".freeze

    def receive_comment_string string
      cs = Comment_String__.new string, @pos
      if cs.is_effectively_empty
        @paragraph and flush
      else
        @paragraph ||= Paragraph__.new
        @paragraph.add_comment_string cs
      end ; nil
    end

    def flush
      line = @paragraph.produce_line
      if @is_interactive
        @comment_line_yieldee << "#{ COMMENT_LINE_PREFIX__ }#{ line }"
      else
        @comment_line_yieldee << line
      end
      @paragraph = nil
    end

    class Comment_String__

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

    class Paragraph__

      def initialize
        @a = []
      end

      def add_comment_string cs
        @a.push cs ; nil
      end

      def produce_line
        scn = Callback_.scan.via_nonsparse_array @a
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
      SPACE_ = ' '.freeze

      CONNECTOR_RX__ = /-\z/
    end

       CODE_LINE_PREFIX__ = 'code line:     '
    COMMENT_LINE_PREFIX__ = 'comment line:  '
       SKIP_LINE_PREFIX__ = 'skipping line: '

  end
end
