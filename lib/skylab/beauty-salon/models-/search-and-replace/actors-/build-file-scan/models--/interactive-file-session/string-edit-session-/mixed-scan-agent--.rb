module Skylab::BeautySalon

  module Models_::Search_and_Replace

    module Actors_::Build_file_scan

      class Models__::Interactive_File_Session

        class String_Edit_Session_

          class Mixed_Scan_Agent__

            def initialize x
              @edit_session = x
              @string = x.string
            end

            def build_line_stream
              build_segmented_line_stream.map_by do |segmented_line|
                segmented_line.map do |seg|
                  seg.string
                end * EMPTY_S_
              end
            end

            def build_segmented_line_stream
              stream = build_segment_stream
              Callback_.stream do
                line = nil
                while seg = stream.gets
                  line ||= Segmented_Line_.new
                  line.push seg
                  if seg.has_delimiter
                    break
                  end
                end
                line
              end
            end

            def build_segment_stream
              queue = []
              match = first_engaged_match
              next_begin_stop = @string.length
              next_begin = 0


              load_queue = -> do

                if match
                  if next_begin < match.begin
                    queue.push seg_proc( next_begin, match.begin )
                  end
                  next_begin = match.next_begin
                  queue.push match.to_replacement_segment_stream_proc
                  match = match.next_engaged_match

                elsif next_begin != next_begin_stop
                  queue.push seg_proc( next_begin, @string.length )
                  next_begin = next_begin_stop
                end
              end

              current_p = gets_via_queue = -> do

                if queue.length.zero?
                  load_queue[]
                  if queue.length.zero?
                    current_p = EMPTY_P_
                  end
                end
                if queue.length.nonzero?
                  p = queue.shift
                  current_p = -> do
                    x = p[]
                    if x
                      x
                    else
                      gets_via_queue[]
                    end
                  end
                  current_p[]
                end
              end

              Callback_.stream do
                current_p[]
              end
            end

          private

            def first_engaged_match
              first_engaged_match_from_index 0
            end

            def first_engaged_match_from_index d
              match = @edit_session.match_at_index d
              while match
                match.replacement_is_engaged and break
                match = @edit_session.match_at_index( d += 1 )
              end
              match
            end

            def seg_proc beg_pos, next_begin
              Build_string_segment_proc_[ beg_pos, next_begin, @string, Normal_Segment_ ]
            end
          end
        end
      end
    end
  end
end
