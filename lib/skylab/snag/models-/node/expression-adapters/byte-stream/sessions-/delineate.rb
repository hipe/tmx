module Skylab::Snag

  class Models_::Node

    module Expression_Adapters::Byte_Stream

      class Sessions_::Delineate  # narrative at [#010]

        # try and keep the formatting intact of lines we don't mutate..

        Callback_::Actor.call self, :properties,
          :N_units, :y, :expag, :node

        class << self
          def new_with * a, & oes_p
            new do
              @on_event_selectively = oes_p
              process_arglist_fully a
            end
          end
        end

        def initialize( * )

          @did_flush = false
          @done = false
          super
        end

        def execute

          body = @node.body
          @r = body.r_
          @row_a = body.row_a_

          __express_the_zero_or_more_non_business_leading_lines
          __express_the_business_rows
          __express_the_zero_or_more_non_business_trailing_lines
        end

        def execute_agnostic

          _delineate_object_stream @node.body.to_object_stream_
        end

        def __express_the_zero_or_more_non_business_leading_lines

          if @r.begin.nonzero?
            @r.begin.times do | d |
              _express_immutable_row @row_a.fetch d
            end
          end
          NIL_
        end

        def __express_the_zero_or_more_non_business_trailing_lines

          if @r.end < @row_a.length
            ( @r.end ... @row_a.length ).each do | d |
              _express_immutable_row @row_a.fetch d
            end
          end
          NIL_
        end

        def __express_the_business_rows

          @row_st = Callback_::Stream.via_range( @r ) do | d |
            @row_a.fetch d
          end

          st = @row_st

          row_x = st.gets
          if row_x
            if row_x.is_mutable
              _delineate_object_stream row_x.to_object_stream_, st
            else
              begin
                _express_immutable_row row_x
                row_x = st.gets
                row_x or break
                if row_x.is_mutable
                  __delineate_all_lines_from_NON_first_row row_x, st
                  break
                end
                redo
              end while nil
            end
          end
        end

        def _express_immutable_row row

          @y << row.s
          NIL_
        end

        def _delineate_object_stream o_st, row_st=nil

          s = ""
          @node.ID.express_into_under s, @expag

          ww = _start_word_wrap s.length, :skip_margin_on_first_line

          ww << s

          o = o_st.gets

          if o  # likely but not certain. special case for first business
            # row: output the sub-margin unless *the* *first* object is a)
            # a tag that b) we want to emphasize. (etc)

            unless :tag == o.business_category_symbol && :open == o.intern
              ww << ( SPACE_ * @expag.sub_margin_width )
            end
            _into_wordwrap_flush_remainder_of_object_stream ww, o, o_st
          end

          if row_st
            _into_wordwrap_flush_remainder_of_rows ww, row_st
          end

          ww.flush
        end

        def __delineate_all_lines_from_NON_first_row row, row_st

          s = ""
          @node.ID.express_into_under s, @expag

          ww = _start_word_wrap s.length

          o_st = row.to_object_stream_
          o = o_st.gets
          if o
            _into_wordwrap_flush_remainder_of_object_stream ww, o, o_st
          end
          _into_wordwrap_flush_remainder_of_rows ww, row_st
          ww.flush

          # this method is different from the above counterpart in that
          # 1) it does not express the identifier (altho it does determine
          # the margin from its width) 2) it puts the same margin on every
          # line and 3) it does not do the emphasis hack.
        end

        def _into_wordwrap_flush_remainder_of_rows ww, row_st

          begin
            row = row_st.gets
            row or break

            o_st = row.to_object_stream_
            o = o_st.gets
            o or redo
            _into_wordwrap_flush_remainder_of_object_stream ww, o, o_st
            @done and break
            redo
          end while nil
        end

        def _into_wordwrap_flush_remainder_of_object_stream ww, o, o_st

          begin

            # word-wrap's job function is to put the correct whitespace
            # character (either space or newline) between each "word".
            # having our own whitespace in the input confuses this so:

            if :string == o.business_category_symbol

              s = o.to_s
              if HAS_LEADING_OR_TRAILING_WHITESPACE___ =~ s
                s = s.strip
              end

              if s.length.zero?
                o = o_st.gets
                o or break
                redo
              end

              ww << s  # here (and for now) we don't defer to the string
                       # piece's own autonomy to express itself. we do it.
            else
              o.express_into_under ww, @expag  # probably a tag
            end

            @done and break  # needs [#ba-042]

            o = o_st.gets
            o or break
            redo
          end while nil

          ww.flush
        end

        HAS_LEADING_OR_TRAILING_WHITESPACE___ = /\A[ \t]|[ \t]\z/
          # yes, we could just `.strip` without checking first, but we want
          # to use our tighter criteria for what whitespace qualifies.

        def _start_word_wrap identifer_badge_length, skip_margin=nil

          margin = SPACE_ *
            ( identifer_badge_length + @expag.sub_margin_width )

          @done = false

          n_units = @N_units
          if n_units

            num_units_received = 0
            receive_line = -> line do

              num_units_received += 1
              if n_units == num_units_received
                @done = true
                receive_line = MONADIC_EMPTINESS_
              end

              @y << line  # has newline already, per ww option

              NIL_
            end

            y = ::Enumerator::Yielder.new do | line |
              receive_line[ line ]
            end

          else
            y = @y
          end

          Snag_.lib_.basic::String.word_wrappers::Calm.new_with(
            :downstream_yielder, y,
            :margin, margin,
            :width, @expag.width,
            :add_newlines,
            * skip_margin )

        end

        MONADIC_EMPTINESS_ = -> _ { }
      end
    end
  end
end
