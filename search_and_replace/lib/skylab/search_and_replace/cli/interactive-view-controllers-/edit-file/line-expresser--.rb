module Skylab::SearchAndReplace

  module CLI

    class Interactive_View_Controllers_::Edit_File

      class Line_Expresser__

        # event-based expression of lines: style the match of interest

        def initialize y

          @line_yielder = y

          @on_newline_sequence = -> s do
            @_buffer.concat s ; nil
          end
        end

        attr_accessor(
          :on_orig_str,
          :on_repl_str,
          :on_disengaged_match_begin,
          :on_disengaged_match_end,
          :on_replacement_begin,
          :on_replacement_end,
        )

        def call any_st
          if any_st
            ___on_throughput_line_stream any_st
          end
        end

        def ___on_throughput_line_stream st

          begin
            x = st.gets
            x or break
            @_buffer = ""  # allocate new memory for each line (for now)
            x.each do | sym, * a |

              if :zero_width == sym
                sym = a.shift
              end

              instance_variable_get( OP_H___.fetch sym ).call( * a )
            end
            @line_yielder << @_buffer
            redo
          end while nil
          @_buffer = nil ; nil
        end

        OP_H___ = {

          orig_str: :@on_orig_str,
          repl_str: :@on_repl_str,

          disengaged_match_begin: :@on_disengaged_match_begin,
          disengaged_match_end: :@on_disengaged_match_end,
          newline_sequence: :@on_newline_sequence,
          replacement_begin: :@on_replacement_begin,
          replacement_end: :@on_replacement_end,
        }

        def concat x
          @_buffer.concat x ; nil
        end
      end
    end
  end
end
