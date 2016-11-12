module Skylab::TMX

  class Operations_::Map

    class Pager___
      # -
        def initialize o
          @clent = o
          @argument_scanner = o.argument_scanner
        end

        def execute
          _at THESE___
        end

        THESE___ = {
          item_count: :__when_item_count,
        }

        def __when_item_count
          _advance_one
          _at FIRST_BRANCH___
        end

        FIRST_BRANCH___ = {
          page_size: :__at_page_size,
        }

        def __at_page_size
          if __parse_non_negative_nonzero_integer
            _at ONLY_ONE_PRIMARY_AVAILABLE_HERE___
          end
        end

        ONLY_ONE_PRIMARY_AVAILABLE_HERE___ = {
          page_offset: :__at_page_offset,
        }

        def __at_page_offset
          if __parse_non_negative_integer
            FIRST_EVER_PAGER.new( @page_offset, @page_size, & @argument_scanner.listener )
          end
        end

        # --

        def __parse_non_negative_nonzero_integer
          _parse_one_such_number :number_set, :integer, :minimum, 1
        end

        def __parse_non_negative_integer
          _parse_one_such_number :number_set, :integer, :minimum, 0
        end

        def _parse_one_such_number * a

          as = @argument_scanner
          sym = as.current_primary_symbol
          kn = as.parse_primary_value_as_one_such_number_via_mutable_array a
          if kn
            instance_variable_set :"@#{ sym }", kn.value_x
            ACHIEVED_
          end
        end

        def _at h
          m = @argument_scanner.match_primary_route_value_against h
          if m
            send m
          end
        end

        def _advance_one
          @argument_scanner.advance_one
        end

      # -

      # ==

      class FIRST_EVER_PAGER

        def initialize d, d_, & p
          @listener = p
          @page_offset = d
          @page_size = d_
        end

        attr_writer(
          :stream,
        )

        def execute

          countdown = @page_size
          current_page_offset = 0
          money_time = nil
          p = nil
          real_st = @stream
          skippy_time = nil

          decidey_time = -> do
            if @page_offset == current_page_offset
              p = money_time
              p[]
            else
              p = skippy_time
              p[]
            end
          end

          money_time = -> do
            x = real_st.gets
            if x
              countdown -= 1
              if countdown.zero?
                us = real_st.upstream
                if us
                  self._README
                  # if you wanted to close the stream it would happen here
                end
                p = EMPTY_P_
              end
            else
              p = EMPTY_P_
            end
            x
          end

          skippy_time = -> do

            big_countdown = @page_size * @page_offset
            begin
              _node = real_st.gets
              if ! _node
                __emit_this_one_thing big_countdown
                x = UNABLE_
                break
              end
              big_countdown -= 1
              if big_countdown.nonzero?
                redo
              end
              p = money_time
              x = p[]
              break
            end while above
            x
          end

          p = decidey_time

          Common_.stream do
            p[]
          end
        end

        def __emit_this_one_thing big_countdown

          @listener.call :error, :expression, :page_content_ended_early do |y|
            y << "stream content ended before reaching target page (had #{ big_countdown } to go)"
          end
          NIL
        end
      end

      # ==
    end
  end
end
# #history: fully repurposed from old [ts] slowie "divvy" operation
