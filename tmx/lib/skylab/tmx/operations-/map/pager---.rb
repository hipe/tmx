module Skylab::TMX

  class Operations_::Map

    class Pager___
      # -
        def initialize o
          @argument_scanner = o.argument_scanner
          @listener = @argument_scanner.listener
        end

        def execute

          m = @argument_scanner.match_branch(
            :business_item, :value, :against_hash, THESE___ )

          if m
            send m
          end
        end

        THESE___ = {
          item_count: :__when_item_count,
        }

        def __when_item_count
          _advance_one
          _primary FIRST_BRANCH___
        end

        FIRST_BRANCH___ = {
          page_size: :__at_page_size,
          page_size_denominator: :__at_page_size_denominator,
        }

        def __at_page_size_denominator
          @_build = :__build_divided_item_count_pager
          if _parse_non_negative_nonzero_integer
            _currently_there_is_one_required_term_from_here
          end
        end

        def __at_page_size
          @_build = :__build_simple_item_count_pager
          if _parse_non_negative_nonzero_integer
            _currently_there_is_one_required_term_from_here
          end
        end

        def _currently_there_is_one_required_term_from_here
          _primary ONLY_ONE_PRIMARY_AVAILABLE_HERE___
        end

        ONLY_ONE_PRIMARY_AVAILABLE_HERE___ = {
          page_offset: :__at_page_offset,
        }

        def __at_page_offset
          if __parse_non_negative_integer
            send @_build
          end
        end

        def __build_divided_item_count_pager
          DividedItemCountPager___.new @page_offset, @page_size_denominator, & @listener
        end

        def __build_simple_item_count_pager
          SimpleItemCountPager___.new @page_offset, @page_size, & @listener
        end

        # --

        def _parse_non_negative_nonzero_integer
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

        def _primary h
          m = @argument_scanner.match_branch :primary, :value, :against_hash, h
          if m
            send m
          end
        end

        def _advance_one
          @argument_scanner.advance_one
        end

      # -

      class DividedItemCountPager___

        # make sense of requests like "first third", "fourth quarter", etc.
        # NOTE - in order to chunk into pages this must know the page size.
        # in order to determine the page size it must know the total number
        # of items. in order to know *that* it must "gulp" ALL of the items
        # and memoize EVERY one (even though it is producing only a slice of
        # them). as such this pager does not scale to large result streams.

        def initialize d, d_, & p
          @listener = p
          @page_offset = d
          @page_size_denominator = d_
        end

        attr_writer(
          :stream,
        )

        def execute

          @_item_array = @stream.to_a
          @_item_count = @_item_array.length
          case 1 <=> @_item_count
          when -1 ; __normally
          when 0 ; Common_::Stream.via_item @_item_array.first
          when 1 ; Common_::Stream.the_empty_stream
          end
        end

        def __normally

          d = @page_offset
          r_st = __range_stream

          begin
            couple = r_st.gets
            if ! couple
              __emit_this_other_thing d
              x = UNABLE_
              break
            end
            if d.zero?
              x = Stream_[ @_item_array[ * couple ] ]
              break
            end
            d -= 1
            redo
          end while above

          x
        end

        def __emit_this_other_thing d

          @listener.call :error, :expression, :page_content_ended_early do |y|
            y << "stream content ended before reaching target page (#{ d += 1 } page(s) short)"
          end
          NIL
        end

        def __range_stream  # exactly [#br-073.B]

          len = @_item_count

          real_page_size = Rational( len ) / Rational( @page_size_denominator )
          whole, fraction = real_page_size.divmod 1

          one = Rational( 1 )  # meh
          rolling_surplus = Rational( 0 )

          current_begin = 0

          p = -> do

            # ~ is this a normal jump or a wide jump?

            width = whole

            rolling_surplus += fraction
            if one <= rolling_surplus
              width += 1
              rolling_surplus -= one
            end

            # ~

            this_begin = current_begin
            current_begin += width

            case current_begin <=> len
            when -1 ; NOTHING_
            when 0  ; p = EMPTY_P_
            else    ; self._SANITY  # extra cautious for now. "should" never happen
            end

            # ~

            [ this_begin, width ]
          end

          Common_.stream do
            p[]
          end
        end
      end

      # ==

      class SimpleItemCountPager___

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
