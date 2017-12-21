module Skylab::Brazen

  class RasterMagnetics::ScaledTimeLineItemStream_via_Glypher

    class SubMagnetics_::ExpressHeaders_via_Arguments

          def initialize *a

            @text_downstream,
            @row_bucket_boxes,
            @first_bucket_begin_datetime,
            @bucket_count,
            @column_A_max_width,
            @days_per_bucket,
            @tua,
            @hook_outs = a
          end

          def execute

            __determine_indexes_of_rows_with_content
            __pre_render_as_lines
            __post_render_sideways
            NIL_
          end

          def __determine_indexes_of_rows_with_content

            h = {}

            @row_bucket_boxes.each do | bx |

              bx or next

              bx.a_.each do | d |
                h[ d ] = true
              end

              # you *could* check if length here of hash is equal to
              # width in buckets to short circuit, but it is expected
              # that in practice these matrixes will usually be sparese
            end

            @bucket_has_content_via_index = h

            NIL_
          end

          def __pre_render_as_lines

            st = __build_bucket_ID_stream
            o = st.gets

            if o

              @lines = []
              __render_first_line o

              sumzn = Summarization___.new @lines, nil, nil, FOUR_

              begin

                sumzn.prev = o

                o = st.gets
                o or break

                sumzn.subject = o

                @hook_outs.within sumzn

                redo
              end while nil
            end
          end

          Summarization___ = ::Struct.new :downstream, :prev, :subject, :width

          def __build_bucket_ID_stream

            next_datetime = -> do
              dt = @first_bucket_begin_datetime
              this_hookout = @tua
              next_datetime = -> do
                dt = this_hookout.next_bucket_begin_datetime_after_ dt
              end
              dt
            end

            has_content = @bucket_has_content_via_index

            Common_::Stream.via_times @bucket_count do | d |

              Bucket_ID__.new next_datetime[], has_content[ d ], d
            end
          end

          Bucket_ID__ = ::Struct.new :normal_datetime, :has_content, :bucket_index

          def __render_first_line o

            # the first line is always the year.

            Levels_::Annual.within__ @lines, o, FOUR_

            NIL_
          end

          def __post_render_sideways

            blank_margin = SPACE_ * ( @column_A_max_width + A_B_SEPARATOR_WIDTH_ )

            s = SPACE_ * @lines.length

            FOUR_.times do |d|

              @lines.each_with_index do |line, idx|

                s[ idx ] = if line
                  line[ d, 1 ] || SPACE_
                else
                  SPACE_
                end
              end

              @text_downstream << "#{ blank_margin }#{ s }#{ NEWLINE_ }"
            end
            NIL_
          end
    end
  end
end
