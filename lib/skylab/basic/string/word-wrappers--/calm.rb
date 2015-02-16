module Skylab::Basic

  module String

    class Word_Wrappers__::Calm

      Callback_::Actor.methodic self, :properties,

        :downstream_yielder,
        :margin,
        :width

      def initialize & edit_p

        @margin = nil
        @pieces = []
        @scn = Basic_.lib_.string_scanner EMPTY_S_

        instance_exec( & edit_p )
      end

    private

      def input_string=
        _receive_input_string iambic_property
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

        @pieces.clear
        @downstream_yielder
      end

      def flush_via_fit_ fit

        p = if @margin
          -> s do
            "#{ @margin }#{ s }"
          end
        else
          IDENTITY_
        end

        y = @downstream_yielder
        fit.line_pairs.each_slice 2 do | d, d_ |

          _s_a = ( d .. d_ ).map do | d__ |
            p[ @pieces.fetch( d__ ).s ]
          end

          y << ( _s_a * EMPTY_S_ )
        end

        nil
      end

      def _receive_input_string s

        st = __build_inbound_piece_scanner s
        pc = st.gets
        if pc

          if @pieces.length.nonzero? && :non_space == @pieces.last.category_symbol

            # insert an "artificial" space between this first incoming
            # word and any last word from any last input chunk

            _accept_piece Piece__.new( SPACE_, :space )
          end
          _accept_piece pc
        end

        begin
          pc = st.gets
          pc or break
          _accept_piece pc
          redo
        end while nil

        self
      end

      def _accept_piece pc
        pc.piece_index = @pieces.length
        @pieces.push pc
        nil
      end

      def __build_inbound_piece_scanner s

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

        Callback_::stream do
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

        attr_reader :line_pairs

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

          @line_count = @line_pairs.length / 2

          freeze
        end
      end
    end
  end
end
