module Skylab::BeautySalon

  module Models_::Search_and_Replace

    module Actors_::Build_file_scan

      class Models__::Interactive_File_Session

        class String_Edit_Session_

          class Build_context_scanners__

            def initialize * a
              @num_before, @match_index, @num_after, @match_a, @string = a
              @match = @match_a[ @match_index ]
            end

            def execute
              [ build_before_stream, build_match_stream, build_after_stream ]
            end

            def build_after_stream
              if @num_after.zero?
                p = EMPTY_P_
              else
                num_lines_started = 0
                p = -> do
                  line = nil
                  while seg = @seg_stream.gets
                    if ! line
                      line = Segmented_Line_.new
                      num_lines_started += 1
                    end
                    line.push seg
                    if seg.has_delimiter
                      break
                    end
                  end
                  if @num_after == num_lines_started
                    p = EMPTY_P_
                  end
                  line
                end
              end
              Callback_.stream do
                p[]
              end
            end

            def build_match_stream

              @seg_stream = segment_stream_from @match

              line = if @first_interest_line
                x = @first_interest_line
                @first_interest_line = nil
                x
              end

              p = -> do
                while seg = @seg_stream.gets
                  line ||= Segmented_Line_.new
                  line.push seg
                  if seg.is_in_match
                    if @match.match_index != seg.match_index
                      end_of_match_reached = true
                    end
                  else
                    end_of_match_reached = true
                  end
                  if seg.has_delimiter
                    break
                  end
                end
                if end_of_match_reached
                  p = EMPTY_P_
                end
                if line
                  x = line
                  line = nil
                  x
                end
              end

              Callback_.stream do
                p[]
              end
            end

            def build_before_stream

              stream = backwards_segment_stream_from @match  # #note-185

              while seg = stream.gets
                if seg.has_delimiter
                  break
                else
                  interest_head ||= Segmented_Line_.new
                  interest_head.push seg
                end
              end
              @first_interest_line = if interest_head
                interest_head.reverse!
              end
              if seg
                do_build_before_stream seg, stream
              else
                Callback_::Stream.the_empty_stream
              end
            end

            def do_build_before_stream seg, stream
              lines = [ line = Segmented_Line_.new ]
              begin
                line.push seg
                seg = stream.gets
                if seg
                  if seg.has_delimiter
                    line.reverse!
                    if @num_before == lines.length
                      break
                    else
                      lines.push line=Segmented_Line_.new
                      redo
                    end
                  else
                    redo
                  end
                else
                  line.reverse!
                  break
                end
              end while nil
              lines.reverse!
              Callback_::Stream.via_nonsparse_array lines
            end

            def segment_stream_from match
              body_p_p = norm_p_p = next_p_p = nil
              do_current_match = current_p = -> do
                curr = body_p_p[]
                queue = []
                nm = match.next_match
                p = norm_p_p[ nm ] and queue.push p
                nm and p = next_p_p[ nm ] and queue.push p
                current_p = -> do
                  x = curr[]
                  x or begin
                    if queue.length.zero?
                      current_p = EMPTY_P_
                      nil
                    else
                      curr = queue.shift
                      current_p[]
                    end
                  end
                end
                current_p[]
              end

              body_p_p = -> do
                if match.replacement_is_engaged
                  match.to_replacement_segment_stream_proc
                else
                  string_segment_proc match.begin, match.next_begin, @string,
                    Match_Segment_.new( match.match_index, :original )
                end
              end

              norm_p_p = -> nm do
                d = match.next_begin
                maybe = if nm
                  nm.begin
                else
                  @string.length
                end
                if d != maybe
                  string_segment_proc d, maybe, @string, Normal_Segment_
                end
              end

              next_p_p = -> next_match do
                -> do
                  match = next_match
                  current_p = do_current_match
                  current_p[]
                end
              end

              Callback_.stream do
                current_p[]
              end
            end

            def backwards_segment_stream_from match
              norm_p_p = rest_p_p = finish = nil
              current_p = backwards_from_match = -> do
                queue = []
                nm = match.previous_match
                p = norm_p_p[ nm ] and queue.push p
                nm and p = rest_p_p[ nm ] and queue.push p  # must be last in queue
                with_queue = -> do
                  case queue.length
                  when 0
                    finish[]
                  when 1
                    current_p = queue.first
                    current_p[]
                  else
                    curr = queue.shift
                    current_p = -> do
                      x = curr[]
                      x or with_queue[]
                    end
                    current_p[]
                  end
                end
                with_queue[]
              end

              norm_p_p = -> nm do
                d = match.begin
                maybe = if nm
                  nm.next_begin
                else
                  0
                end
                if d != maybe
                  backwards_string_segment_proc maybe, d, @string, Normal_Segment_
                end
              end

              rest_p_p = -> nm do
                -> do
                  p = if nm.replacement_is_engaged
                    backwards_string_segment_proc 0, nm.replacement_string,
                      Match_Segment_.new( nm.match_index, :replacement )
                  else
                    backwards_string_segment_proc nm.begin, nm.next_begin,
                      @string, Match_Segment_.new( nm.match_index, :original )
                  end
                  current_p = -> do
                    x = p[]
                    x or begin
                      match = nm
                      current_p = backwards_from_match
                      current_p[]
                    end
                  end
                  current_p[]
                end
              end

              finish = -> do
                current_p = EMPTY_P_
                nil
              end

              Callback_.stream do
                current_p[]
              end
            end

            def string_segment_proc beg_pos=nil, next_begin=nil, string, cls
              beg_pos ||= 0
              next_begin ||= string.length
              Build_string_segment_proc_[ beg_pos, next_begin, string, cls ]
            end

            def backwards_string_segment_proc beg_pos=nil, next_begin=nil, string, cls
              beg_pos ||= 0
              next_begin ||= string.length
              if beg_pos == next_begin  # if you ask for the empty string, you get it
                p = -> do
                  p = EMPTY_P_
                  cls.new EMPTY_S_, 0
                end
              else
                p = -> do
                  right = next_begin - 1
                  left = right
                  while left != beg_pos
                    d = left - 1
                    DELIM_BYTE_ == string.getbyte( d ) and break
                    left = d
                  end
                  if left == beg_pos
                    p = EMPTY_P_
                  else
                    next_begin = left
                  end
                  cls.new string[ left .. right ], left
                end
              end
              -> do
                p[]
              end
            end
          end
        end
      end
    end
  end
end
