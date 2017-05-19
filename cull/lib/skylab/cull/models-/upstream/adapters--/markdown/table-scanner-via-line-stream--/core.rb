module Skylab::Cull

  module Models_::Upstream

    class Adapters__::Markdown

      class Table_scanner_via_line_stream__ < Common_::Monadic

        # our "grammar" for what constitutes a github-flavored markdown table
        # is probably not a perfect subset nor superset of the emergent
        # grammar of the github-flavored markdown parser:
        #
        # because of our needs below it may be the case that there exist
        # some GFM tables that are not GFM [cu]-compatible tables, because
        # our [cu] tables require at least 2 rows and 2 columns (maybe to
        # both). (we have yet to find out if GFM itself has either or both
        # of these requirements.)
        #
        # as well it may be the case that we recognize some strings as a
        # "table" for [cu] that are not recognized as a table in GFM, becuase
        # of our hack for horizontal tables involve skipping the use of
        # the hyphenated dividing line between the header row and the first
        # body row.
        #
        # to cheat this "syntax" further into our universe, we have added
        # safeguards agaist mis-identifying as a table glyphs that are
        # actually part of an ASCII diagram. this part (although ony a few
        # lines of code) is nasty on principle and will need cleaning when
        # the dust settles.
        #
        # despite all of this, for vertical tables the input data
        # of our specs *is* relevant excerpts from the github documentation.
        #
        # our goal is to meet our own needs first and then only secondly try
        # to bend this to fit into GFM as necessary. the requirements of our
        # own grammar are twofold:
        #
        #   1) classify each table as having an axis that is either
        #      "goofy" or "conventional" (explained below)
        #
        #   2) avoid mis-classification as table an entity that is in fact
        #      part of an ASCII-digram (also explained below).
        #
        # our "grammar" requires one line of lookahead in order to accomodate
        # each of the above requirements variously.
        #
        # ("common" is where each new "record" adds a line to the file, and
        #  "goofy" is where each new "record" adds a "column" to the table,
        #  visually. depending on the tendencies of the data, these two axes
        #  have their own optimality.)
        #

        def initialize ls, & p
          @is_inside_of_a_table = false
          @line_stream = ls
          @_emit = p
          @strscn = nil
        end

        def execute
          self
        end

        def gets
          if @is_inside_of_a_table
            gets_when_inside_of_a_table
          else
            gets_when_normal
          end
        end

      private

        def gets_when_inside_of_a_table
          line = @line_stream.gets
          while line
            if line.include? PIPE_S_
              line = @line_stream.gets
            else
              # throw away this current line
              @is_inside_of_a_table = false
              x = gets_when_normal
              break
            end
          end
          x
        end


        def gets_when_normal
          @line = @line_stream.gets
          @line and begin
            @next_line = @line_stream.gets
            @next_line and via_second_line
          end
        end

        def via_second_line
          begin
            if @next_line.include? PIPE_S_
              x = advance_when_next_line_has_pipe
              x and break
            else
              advance_by_one
            end
          end while @next_line
          x
        end

        def advance_when_next_line_has_pipe

          # assume previous line does not have a pipe

          sexp = table_row_sexp_via_line @next_line

          _found = sexp.pipes.detect do | pipe |

            PLUS_BYTE__ == @line.getbyte( pipe.offset )

          end

          if _found
            advance_past_ascii_graph_section  # #todo
          else
            advance_via_sexp sexp
          end
        end

        PLUS_BYTE__ = '+'.getbyte 0

        def advance_via_sexp sexp
          @line = @next_line
          @next_line = @line_stream.gets
          if @next_line
            if @next_line.include? PIPE_S_
              advance_via_first_2_rows sexp, table_row_sexp_via_line( @next_line )
            else
              advance_by_one
            end
          end
        end

        def table_row_sexp_via_line line
          a = []
          d = 0
          md = PIPE_RX__.match line, d
          begin
            beg = md.begin 0
            a.push Pipe__.new beg
            d = beg + 1
            md = PIPE_RX__.match line, d
            md ? redo : break
          end while nil
          Table_Row_Sexp__.new a, line
        end

        PIPE_RX__ = /(?<!\\)\|/

        def advance_via_first_2_rows sexp, sexp_

          if sexp.number_of_pipes == sexp_.number_of_pipes

            @is_inside_of_a_table = true

            _s = if sexp.has_aesthetic_leading_pipe
              sexp_.full_cel_content_after_pipe_at_index( 0 )
            else
              sexp_.full_cel_content_before_first_pipe
            end

            if HYPHEN_CEL_RX__ =~ _s
              go_vertical sexp
            else
              go_horizontal
            end
          else
            advance_by_one
          end
        end

        HYPHEN_CEL_RX__ = /\A[ \t]*:?-+:?[ \t]*\z/

        def go_vertical sexp
          Self__::Vertical__.new @line_stream, sexp, & @_emit
        end

        def go_horizontal
          Self__::Horizontal__.new @line_stream, @next_line, @line,
            & @_emit
        end

        def advance_by_one
          @line = @next_line
          @next_line = @line_stream.gets
          nil
        end

        class Table_Row_Sexp__

          def initialize a, line
            @a = a
            @line = line
          end

          def number_of_pipes
            @a.length
          end

          def pipes
            @a
          end

          def has_aesthetic_leading_pipe
            d = @a.fetch( 0 ).offset
            if d.zero?
              true
            else
              BLANK_NONEMPTY_RX__ =~ @line[ 0, d ]
            end
          end

          BLANK_NONEMPTY_RX__ = /\A[ \t]+\z/

          def full_cel_content_after_pipe_at_index d

            _pipe = @a.fetch d

            d_ = d + 1
            if d_ < @a.length
              _pipe_ = @a.fetch d_
              _next_begin = _pipe_.offset
            else
              _next_begin = @line.length
            end

            @line[ _pipe.offset + 1 ... _next_begin ]
          end

          def full_cel_content_before_first_pipe
            _pipe = @a.fetch 0
            @line[ 0, _pipe.offset ]
          end
        end

        Pipe__ = ::Struct.new :offset do
          def symbol_name
            :pipe
          end
        end

        ANY_WHITESPACE_AND_A_PIPE_RX_ = /[ \t]*\|/

        NOT_PIPE_RX_ = /(?:
            \\ \|                 # a backslash follwed by a pipe
          | [^\|\n]               # or anything other than a pipe
        )*/x                      # zero of them is still a match

        PIPE_RX_ = /\|/

        PIPE_S_ = '|'

        Self__ = self
      end
    end
  end
end
