module Skylab::Brazen

  class RasterMagnetics::ScaledTimeLineItemStream_via_Glypher

    class SubMagnetics_::ExpressHeaders_via_Arguments

      class << self
        def call_by **hh
          new( ** hh ).execute
        end
        private :new
      end

      # -

        def initialize(
          text_downstream: nil,
          hook_outs: nil,
          row_block_boxes: nil,
          first_block_begin_datetime: nil,
          days_per_block: nil,
          block_count: nil,
          time_unit_adapter: nil,
          business_column_max_width: nil
        )

          @text_downstream = text_downstream
          @hook_outs = hook_outs
          @row_block_boxes = row_block_boxes
          @first_block_begin_datetime = first_block_begin_datetime
          @days_per_block = days_per_block
          @block_count = block_count
          @time_unit_adapter = time_unit_adapter
          @business_column_max_width = business_column_max_width
        end

        def execute
            __determine_indexes_of_rows_with_content
            __pre_render_as_lines
            __post_render_sideways
          @text_downstream
        end

          def __determine_indexes_of_rows_with_content

            h = {}

            @row_block_boxes.each do | bx |

              bx or next

              bx.a_.each do | d |
                h[ d ] = true
              end

              # you *could* check if length here of hash is equal to
              # width in blocks to short circuit, but it is expected
              # that in practice these matrixes will usually be sparese
            end

            @block_has_content_via_index = h

            NIL_
          end

          def __pre_render_as_lines

            st = __build_block_ID_stream
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

          def __build_block_ID_stream

            next_datetime = -> do
              dt = @first_block_begin_datetime
              this_hookout = @time_unit_adapter
              next_datetime = -> do
                dt = this_hookout.next_block_begin_datetime_after_ dt
              end
              dt
            end

            has_content = @block_has_content_via_index

            Common_::Stream.via_times @block_count do | d |

              BlockID___.new next_datetime[], has_content[ d ], d
            end
          end

          def __render_first_line o

            # the first line is always the year.

            Levels_::Annual.within__ @lines, o, FOUR_

            NIL_
          end

          def __post_render_sideways

          w = @business_column_max_width
          if w
            blank_margin = SPACE_ * ( w+ A_B_SEPARATOR_WIDTH_ ) ; w = nil
          end

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

      # ==

      BlockID___ = ::Struct.new(
        :normal_datetime,
        :has_content,
        :block_index,
      )

      # ==
      # ==
    end
  end
end
