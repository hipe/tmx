module Skylab::Basic

  module String

    class Word_Wrappers__::Calm  # :+[#033].

      Callback_::Actor.methodic self, :properties,

        :downstream_yielder,
        :margin,
        :width

      def initialize & edit_p

        @do_add_newlines = false
        @do_margin_on_first_line = true
        @first_line_is_done = false
        @margin = nil
        @pending_width = 0
        @pieces = []
        @_q = nil
        @scn = Basic_.lib_.string_scanner EMPTY_S_
        @width = nil
        instance_exec( & edit_p )
      end

    private

      def add_newlines=
        @do_add_newlines = true
        KEEP_PARSING_
      end

      def aspect_ratio=
        extend Basic_::String::Fit_to_Aspect_Ratio_::Methods
        @ratio_a = iambic_property
        KEEP_PARSING_
      end

      def input_string=
        ( @_q ||= [] ).push :_receive_input_string, iambic_property
        KEEP_PARSING_
      end

      def input_words=
        ( @_q ||= [] ).push :__receive_input_words, iambic_property
        KEEP_PARSING_
      end

      def skip_margin_on_first_line=
        @do_margin_on_first_line = false
        KEEP_PARSING_
      end

    public

      def << s
        _receive_input_string s
        self
      end

      def execute
        # the one-off form
        if @_q
          q = @_q ; @_q = nil
          q.each_slice 2 do | method, x |
            send method, x
          end
        end
        flush
      end

      def flush

        ftw = Fit_to_Width.new @pieces

        if @margin

          @pending_width = @margin.length

          len = @margin.length
          subsequent_width = if len >= @width
            0
          else
            @width - len
          end

          first_width = if @do_margin_on_first_line || @first_line_is_done
            subsequent_width
          else
            @width
          end

        else

          @pending_width = 0
          first_width = subsequent_width = @width
        end

        flush_via_fit_ ftw.fit_to_width( first_width, subsequent_width )
      end

      def flush_via_fit_ fit

        non_margin_proc = if @do_add_newlines
          -> s do
            "#{ s }\n"
          end
        else
          IDENTITY_
        end

        if @margin  # easier to follow this way, but not "elegant"

          p = if @do_add_newlines
            -> s do
              "#{ @margin }#{ s }\n"
            end
          else
            -> s do
              "#{ @margin }#{ s }"
            end
          end

          if ! @do_margin_on_first_line && ! @first_line_is_done
            next_p = p
            p = -> s do
              @first_line_is_done = true
              x = non_margin_proc[ s ]
              p = next_p
              x
            end
          end
        else
          p = non_margin_proc
        end

        y = @downstream_yielder
        fit.line_pairs.each_slice 2 do | d, d_ |

          _s_a = ( d .. d_ ).map do | d__ |
            @pieces.fetch( d__ ).s
          end

          y << p[ _s_a * EMPTY_S_ ]
        end

        @pieces.clear
        @downstream_yielder
      end

      def __receive_input_words s_a

        _receive_piece_stream __build_inbound_piece_scanner_via_array s_a
        nil
      end

      def _receive_input_string s

        _receive_piece_stream _build_inbound_piece_scanner_via_string s
        NIL_
      end

      def _receive_piece_stream st

        pc = st.gets
        if pc
          if :particular_space != pc.category_symbol
            __add_artificial_space_if_necessary
          end
          _accept_piece pc
          begin
            pc = st.gets
            pc or break
            _accept_piece pc
            redo
          end while nil
        end

        nil
      end

      def __add_artificial_space_if_necessary

        # insert an "artificial" space between this first incoming
        # word and any last word from any last input chunk

        if @pieces.length.nonzero? && :non_space == @pieces.last.category_symbol
          _add_artificial_space
        end

        nil
      end

      def _add_artificial_space
        _accept_piece Piece__.new( SPACE_, :space )
        nil
      end

      def _accept_piece pc

        d = @pieces.length
        pc.piece_index = d
        @pieces.push pc
        @pending_width += pc.length

        if @width && @pending_width >= @width  # [#007] this could be made an option
          flush
        end

        nil
      end

      def __build_inbound_piece_scanner_via_array s_a

        ary_st = Callback_::Stream.via_nonsparse_array s_a

        non_initial_p = nil
        p = nil
        p_for_special = nil

        initial_p = -> do
          s = ary_st.gets
          if s
            if SPECIAL_RX___ =~ s
              p = p_for_special[ s, initial_p ]
              p[]
            else
              p = non_initial_p
              Piece__.new s, :non_space
            end
          else
            p = EMPTY_P_
            nil
          end
        end

        p_for_special = -> s, then_p do
          st = _build_inbound_piece_scanner_via_string s
          -> do
            x = st.gets
            if x
              p = -> do
                x_ = st.gets
                if x_
                  x_
                else
                  p = non_initial_p
                  p[]
                end
              end
              x
            else
              p = then_p
              p[]
            end
          end
        end

        non_initial_p = -> do
          s = ary_st.gets
          if s
            if SPECIAL_RX___ =~ s
              p = p_for_special[ s, non_initial_p ]
              Piece__.new SPACE_, :space
            else
              p = -> do
                p = non_initial_p
                Piece__.new s, :non_space
              end
              Piece__.new SPACE_, :space
            end
          else
            p = EMPTY_P_
            nil
          end
        end

        p = initial_p

        Callback_.stream do
          p[]
        end
      end

      SPECIAL_RX___ = /[[:space:]-]/

      def _build_inbound_piece_scanner_via_string s

        @scn.string = s

        p = main_p = -> do
          if @scn.eos?
            p = EMPTY_P_
            nil
          else

            buffer = []

            word = @scn.scan NOT_SPACES_OR_DASHES___
            dash = @scn.scan SEMANTIC_DASH___

            if word || dash  # meh
              buffer.push Piece__.new( "#{ word }#{ dash }", :non_space )
            end

            space = @scn.scan PARTICULAR_SPACE___
            if space
              buffer.push Piece__.new( space, :particular_space )
            else
              space = @scn.scan SPACE___

              if space
                buffer.push Piece__.new( space, :space )
              end
            end

            x = buffer.shift
            if buffer.length.zero?
              p = main_p
            else
              x_ = buffer.shift
              p = -> do
                p = main_p
                x_
              end
            end
            x
          end
        end

        Callback_.stream do
          p[]
        end
      end

      NOT_SPACES_OR_DASHES___ = /(?:[^[:space:]-]|-{2,})+/
      PARTICULAR_SPACE___ = /[ ]{2,}/  # etc
      SEMANTIC_DASH___ = /-(?!-)/
      SPACE___ = /[[:space:]]+/

      class Piece__

        def initialize s, sym
          @category_symbol = sym
          @s = s
          @length = s.length
        end

        attr_reader :category_symbol, :length, :piece_index, :s

        attr_writer :piece_index
      end

      class Fit_to_Width

        def initialize pieces
          @actual_width = 0
          @_pieces = pieces
          @narrowest_line_width = nil
        end

        attr_reader :actual_width, :line_pairs, :narrowest_line_width

        def fit_to_width w, w_=w

          dup.fit_to_width__ w, w_
        end

        def fit_to_width__ w, w_

          @line_pairs = []
          @_piece_stream = Callback_::Stream.via_nonsparse_array @_pieces

          pc = @_piece_stream.gets
          if pc

            @target_width = w
            pc = __express_line pc
            @target_width = w_

            begin
              if ! pc
                pc = @_piece_stream.gets
              end
              pc or break
              pc = __express_line pc
              redo
            end while nil
          end

          __produce_result
        end

        def __express_line pc

          # skip over leading `space` pieces - don't write them to the
          # line head. (`particular_space` is treated like non-space here.)

          begin
            :space == pc.category_symbol or break
            pc = @_piece_stream.gets
            pc and redo
            break
          end while nil

          if pc
            __express_content_line pc
          end
        end

        def __express_content_line pc  # assumes #the-grammar

          current_line_width = pc.length
          index_of_first_piece = pc.piece_index
          index_of_last_piece = index_of_first_piece

          begin

            pc_ = @_piece_stream.gets
            pc_ or break
            sym = pc_.category_symbol
            if :space == sym || :particular_space == sym
              space_width = pc_.length
              pc_ = @_piece_stream.gets
              pc_ or break
            else
              space_width = 0
            end

            next_line_width = current_line_width + space_width + pc_.length

            case @target_width <=> next_line_width

            when 1  # the potential line is under the limit (and not equal
                    # to the limit). accept this chunk and keep searching.

              current_line_width = next_line_width
              index_of_last_piece = pc_.piece_index
              redo

            when -1  # this potential line goes over the limit.
                     # we are done with this line.

              spare_piece = pc_
              break

            when 0  # this potential line is an exact fit.
                    # we are done with this line.

              current_line_width = next_line_width
              index_of_last_piece = pc_.piece_index
              break
            end

          end while nil

          __accept_line_pair(
            index_of_first_piece, index_of_last_piece, current_line_width )

          spare_piece
        end

        def __accept_line_pair d, d_, line_width

          if @actual_width < line_width
            @actual_width = line_width
          end

          @line_pairs.push d, d_

          if ! @narrowest_line_width || @narrowest_line_width > line_width
            @narrowest_line_width = line_width
          end

          nil
        end

        def __produce_result

          @_pieces = @_piece_stream = nil


          freeze
        end
      end
    end
  end
end
