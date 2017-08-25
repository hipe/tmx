module Skylab::BeautySalon

  class Models_::Deliterate

    class << self

      def describe_into_under y, expag

        countdown = 3
        _use_y = ::Enumerator::Yielder.new do |line|
          y << line
          countdown -= 1
          countdown.zero? and throw :_stop_BS_
        end
        catch :_stop_BS_ do
          Describe_into_under__[ _use_y, expag ]
        end
        y
      end
    end  # >>

    # -

      def initialize
        o = yield
        @_argument_scanner_ = o.argument_scanner
        @_associations_ = {}  # #[#br-011]
      end

      def definition ; [  # to #here1

        :description, -> y do
          self._HELLO__hello__  # #todo
          Describe_into_under__[ y, self ]
        end,

        :required, :property, :comment_line_downstream,

        :required, :property, :code_line_downstream,

        :required, :property, :line_upstream,

        :required,
        :property, :from_line,
        :must_be_integer_greater_than_or_equal_to, 1,

        :required,
        :property, :to_line,
        :normalize_by, -> qkn, & p do
          This_compound_normalization___[].__call_ p, qkn
        end,
      ] ; end

      Describe_into_under__ = -> y, expag do

        _big_string = nil  # (interesting - you get a warning if a heredoc is a result)
        expag.calculate do
          _big_string = <<~O
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
        end  # end calculate

        st = Basic_[]::String::LineStream_via_String[ _big_string ]
        while (( line = st.gets ))
          y << line
        end
        y
    end

    # -
    def execute

      ok = normalize_range
      ok && prepare
      ok && __work
      if ok
        NOTHING_  # all our output is in side effects
      else
        NOTHING_  # downgrade false to nil
      end
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

      foz = @_associations_
      fl = foz.fetch :from_line
      tl = foz.fetch :to_line

      d = @from_line
      d_ = @to_line

      _listener_.call :error, :expression, :upside_down_range do |y|

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

      def line_string
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
        scn = Common_::Stream.via_nonsparse_array @a
        cs = scn.gets
        if cs
          s = cs.line_string
          a = [ s ]
          was_connector = CONNECTOR_RX__ =~ s
        end
        while cs = scn.gets
          s = cs.line_string
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


      def _simplified_write_ x, k
        instance_variable_set :"@#{ k }", x
      end

      def _simplified_read_ k
        ::Kernel._OKAY
      end

      def _listener_
        @_argument_scanner_.listener
      end

      attr_reader(
        :_argument_scanner_,
      )
    # -
    # ==

    This_compound_normalization___ = Lazy_.call do

      CompoundNormalization___.new(
        Must_be_integer___[],
        Must_be_in_a_particular_range___[],
      )
    end

    Must_be_in_a_particular_range___ = -> do
      Basic_[]::Range::Normalization.with(
        :is, -1,
        :or,
        :begin, 1,
      )
    end

    Must_be_integer___ = -> do
      Basic_[]::Number::Normalization.with(
        :number_set, :integer,
      )
    end

    class CompoundNormalization___

      # (compound normalizations happend more concisely "declaratively"
      # under [br] - you could simply chain the declarations in order.
      # here, etc.)

      def initialize first, second, * rest
        @normalizations = [ first, second, * rest ].freeze
      end

      def __call_ p, qkn
        CompoundNormalize___.new( p, qkn, @normalizations ).execute
      end
    end

    class CompoundNormalize___

      def initialize p, qkn, n11n_a
        @listener = p
        @normalizations = n11n_a
        @QKN = qkn
      end

      def execute
        if @QKN.is_effectively_known
          __do_execute
        else
          @QKN.to_knownness
        end
      end

      def __do_execute

        ok = true ; x = nil

        current_QKN = @QKN
        len = @normalizations.length

        0.upto( len - 2 ) do |d|
          _n11n = @normalizations.fetch d
          kn = _n11n.normalize_qualified_knownness current_QKN, & @listener
          if ! kn
            ok = kn ; x = kn ; break
          end
          current_QKN = current_QKN.new_with_value kn.value
        end

        if ok
          _n11n = @normalizations.fetch len - 1
          x = _n11n.normalize_qualified_knownness current_QKN, & @listener
        end
        x
      end
    end

    # ==

    Actions = nil  # provision [#pl-011.3] (we are the action)

    # ==
    # ==
  end
end
# #
# #history-B.1: GUT .. #tombstone-B.2 get rid of old ping
# :+#tombstone: interactive mode
