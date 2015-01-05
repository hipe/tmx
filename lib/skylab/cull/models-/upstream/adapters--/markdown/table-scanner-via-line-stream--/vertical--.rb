module Skylab::Cull

  class Models_::Upstream

    class Adapters__::Markdown

      class Table_scanner_via_line_stream__

        class Vertical__

          def initialize ls, sexp, & oes_p

            last_pipe_index = sexp.number_of_pipes - 1
            d = 0
            p = nil

            main_p = -> do
              if last_pipe_index == d
                s = sexp.full_cel_content_after_pipe_at_index d
                p = EMPTY_P_
                s.chop!
                s.length.nonzero? and s
              else
                s = sexp.full_cel_content_after_pipe_at_index d
                d += 1
                s
              end
            end

            if sexp.has_aesthetic_leading_pipe
              @has_aesthetic_leading_pipe = true
              p = main_p
            else
              @has_aesthetic_leading_pipe = false
              p = -> do
                p = main_p
                sexp.full_cel_content_before_first_pipe
              end
            end

            sym_a = []
            cel_s = p[]
            begin
              cel_s.strip!
              sym_a.push cel_s.intern
              cel_s = p[]
            end while cel_s

            @sym_a = sym_a
            @line_stream = ls
            @scn = Cull_.lib_.string_scanner EMPTY_S_
          end

          def gets

            line = @line_stream.gets
            if line
              if line.include? PIPE_S_
                gets_via_line_with_at_least_one_pipe line
              else
                @line_stream.fh.close
                NIL_
              end
            end
          end

          def gets_via_line_with_at_least_one_pipe line

            @scn.string = line

            if @has_aesthetic_leading_pipe
              @scn.skip ANY_WHITESPACE_AND_A_PIPE_RX_
            end

            Models_::Entity_.new do | ent |

              cel_count = 0

              begin
                s = @scn.scan NOT_PIPE_RX_
                had_pipe = @scn.skip PIPE_RX_
                is_end = NEWLINE_BYTE__ == line.getbyte( @scn.pos )
                s.strip!
                ent.add_actual_property_value_and_name s, @sym_a.fetch( cel_count )
                cel_count += 1
                if is_end
                  if had_pipe && cel_count != @sym_a.length
                    self._DO_ME  # you should probably add an empty cel
                  end
                  break
                end
                redo
              end while nil
            end
          end

          NEWLINE_BYTE__ = "\n".getbyte 0

        end
      end
    end
  end
end
