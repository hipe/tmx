module Skylab::Cull

  class Models_::Upstream

    class Adapters__::Markdown

      class Table_scanner_via_line_stream__

        class Horizontal__

          def initialize ls, line_, line, & oes_p

            # make it look as if we aren't already two lines into the scan:

            p = -> do
              p = -> do
                p = -> do
                  line = ls.gets
                  if line
                    if line.include? PIPE_S_
                      line
                    else
                      ls.fh.close
                      NIL_
                    end
                  end
                end
                line_
              end
              line
            end

            line = p[]

            scn = Home_.lib_.string_scanner line

            if scn.match? ANY_WHITESPACE_AND_A_PIPE_RX_
              has_aesthetic_leading_pipe = true
            end

            cel_s_a_a = []

            max = 0
            begin
              cel_s_a = []
              cel_s_a_a.push cel_s_a

              if has_aesthetic_leading_pipe
                scn.skip ANY_WHITESPACE_AND_A_PIPE_RX_
              end

              count = 0
              begin
                s = scn.scan NOT_PIPE_RX_
                s.strip!
                scn.skip PIPE_RX_
                is_end = scn.skip NEWLINE_RX__
                cel_s_a.push s
                count += 1
                if is_end
                  line = p[]

                  if line
                    if line.include? PIPE_S_
                      scn.string = line
                      do_stay = true
                    else
                      ls.fh.close
                      do_stay = false
                    end
                  else
                    do_stay = false
                  end

                  break
                else
                  redo
                end

              end while nil

              if count > max
                max = count
              end

            end while do_stay

            @max = max
            process_rows cel_s_a_a
          end

          NEWLINE_RX__ = /\n/

        private

          def process_rows cel_s_a_a

            @num_fields = cel_s_a_a.length

            @sym_a = cel_s_a_a.length.times.map do | d |
              cel_s_a_a.fetch( d ).fetch( 0 ).intern
            end

            @rows = cel_s_a_a

            @d = 1

            nil
          end

        public

          def gets
            if @d < @max

              Models_::Entity_.new do | ent |

                @num_fields.times do | d |

                  ent.add_actual_property_value_and_name(
                    @rows.fetch( d )[ @d ],
                    @sym_a.fetch( d ) )

                end

                @d += 1
              end
            end
          end
        end
      end
    end
  end
end
