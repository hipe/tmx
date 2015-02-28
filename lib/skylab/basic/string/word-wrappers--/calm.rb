module Skylab::Basic

  module String

    class Word_Wrappers__::Calm  # :+[#033].

      Callback_::Actor.methodic self, :properties,

        :downstream_yielder,
        :margin,
        :width

      def initialize & edit_p

        @do_add_newlines = false
        @margin = nil
        @pieces = []
        @scn = Basic_.lib_.string_scanner EMPTY_S_

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
        _receive_input_string iambic_property
        KEEP_PARSING_
      end

      def input_words=
        __receive_input_words iambic_property
        KEEP_PARSING_
      end

    public

      def << s
        _receive_input_string s
        self
      end

      def execute
        # the one-off form
        flush
      end

      def flush

        ftw = Fit_to_Width_.new @pieces

        _width = if @margin
          len = @margin.length
          if len >= @width
            0
          else
            @width - len
          end
        else
          @width
        end

        flush_via_fit_ ftw.fit_to_width _width
      end

      def flush_via_fit_ fit

        p = if @margin  # easier to follow this way, but not "elegant"
          if @do_add_newlines
            -> s do
              "#{ @margin }#{ s }\n"
            end
          else
            -> s do
              "#{ @margin }#{ s }"
            end
          end
        elsif @do_add_newlines
          -> s do
            "#{ s }\n"
          end
        else
          IDENTITY_
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
        self
      end

      def _receive_piece_stream st

        pc = st.gets
        if pc
          __add_artificial_space_if_necessary
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
        pc.piece_index = @pieces.length
        @pieces.push pc
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
            word = @scn.scan NOT_SPACES_OR_DASHES___
            dash = @scn.scan SEMANTIC_DASH___
            space = @scn.scan SPACE___

            buffer = []

            if word || dash  # meh
              buffer.push Piece__.new( "#{ word }#{ dash }", :non_space )
            end

            if space
              buffer.push Piece__.new( space, :space )
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

      class Fit_to_Width_

        def initialize pieces
          @actual_width = 0
          @_pieces = pieces
          @narrowest_line_width = nil
        end

        attr_reader :actual_width, :line_pairs, :narrowest_line_width

        def fit_to_width w
          dup.fit_to_width__ w
        end

        def fit_to_width__ w
          @target_width = w
          @line_pairs = []
          @_piece_stream = Callback_::Stream.via_nonsparse_array @_pieces
          @_piece = @_piece_stream.gets
          while @_piece
            __express_line
          end
          __produce_result
        end

        def __express_line

          # interceding whitespace pieces (of any length) are skipped

          while :space == @_piece.category_symbol
            @_piece = @_piece_stream.gets
          end

          if @_piece
            __express_content_line
          end
        end

        def __express_content_line  # assumes #the-grammar

          pc = @_piece
          @_piece = nil

          current_line_width = pc.length
          index_of_first_piece = pc.piece_index
          index_of_last_piece = index_of_first_piece

          begin

            next_piece = @_piece_stream.gets
            next_piece or break
            if :space == next_piece.category_symbol
              space_width = next_piece.length
              next_piece = @_piece_stream.gets
              next_piece or break
            else
              space_width = 0
            end

            next_line_width = current_line_width + space_width + next_piece.length

            case @target_width <=> next_line_width

            when 1  # the potential line is under the limit (and not equal
                    # to the limit). accept this chunk and keep searching.

              current_line_width = next_line_width
              index_of_last_piece = next_piece.piece_index
              redo

            when -1  # this potential line goes over the limit.
                     # we are done with this line.

              @_piece = next_piece
              break

            when 0  # this potential line is an exact fit.
                    # we are done with this line.

              current_line_width = next_line_width
              index_of_last_piece = next_piece.piece_index
              @_piece = @_piece_stream.gets
              break
            end

          end while nil

          __accept_line_pair(
            index_of_first_piece, index_of_last_piece, current_line_width )

          nil
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

          @_piece = @_pieces = @_piece_stream = nil


          freeze
        end
      end
    end
  end
end
