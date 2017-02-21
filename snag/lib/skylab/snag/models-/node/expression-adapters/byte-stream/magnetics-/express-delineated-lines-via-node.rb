module Skylab::Snag

  class Models_::Node

    module ExpressionAdapters::ByteStream

      class Magnetics_::ExpressDelineatedLines_via_Node  # exactly [#010]

        # try and keep the formatting intact of lines we don't mutate..

        Attributes_actor_.call( self,
          :N_units,
          :y,
          :expag,
          :node,
        )

        class << self

          def new_via * a
            sess = new
            _kp = sess.process_arglist_fully a
            _kp && sess
          end

          private :new
        end  # >>

        def initialize
          @did_flush = false
          @done = false
        end

        def execute

          body = @node.body
          @r = body.r_
          @row_a = body.row_a_

          __express_any_leading_non_business_lines
          __express_any_business_rows
          __express_any_trailing_non_business_lines
        end

        def execute_agnostic

          _from_head_via_object_stream @node.body.to_object_stream_
        end

        def __express_any_leading_non_business_lines

          if @r.begin.nonzero?
            @r.begin.times do | d |
              _express_immutable_row @row_a.fetch d
            end
          end
          NIL_
        end

        def __express_any_trailing_non_business_lines

          if @r.end < @row_a.length
            ( @r.end ... @row_a.length ).each do | d |
              _express_immutable_row @row_a.fetch d
            end
          end
          ACHIEVED_
        end

        def __express_any_business_rows

          st = Common_::Stream.via_range @r do | d |
            @row_a.fetch d
          end

          first_row = st.gets

          if first_row
            __express_the_business_rows first_row, st
          end
          NIL_
        end

        def __express_the_business_rows first_row, st

          if first_row.is_mutable

            _from_head_via_object_stream(

              first_row.to_object_stream_( st ),
              st )
          else

            _express_immutable_row first_row
            __express_any_subsequent_business_rows st
          end
          NIL_
        end

        def __express_any_subsequent_business_rows st

          # with every zero or more remaining business row: if that row
          # is non-mutable, output the raw, received string (just as it
          # existed in the presumed upsream file). otherwise, (and that
          # row is mutable), wordwrap into one flow all objects in that
          # row and any remaining business rows of this node regardless
          # of whether or not they were mutated; to preserves the human
          # formatting where it can, and trample human formatting where
          # the machine formatting would otherwise produce lines too wide
          # or too narrow.

          begin
            row = st.gets
            row or break

            if row.is_mutable
              __from_non_head_via_object_stream row, st
              break
            end
            _express_immutable_row row
            redo
          end while nil
          NIL_
        end

        def _express_immutable_row row

          @y << row.s
          NIL_
        end

        def _from_head_via_object_stream o_st, row_st=nil

          s = _get_ID_description

          ww = _start_word_wrap s.length, :skip_margin_on_first_line

          ww << s

          o = o_st.gets

          if o  # likely but not certain.

            # :+#special-logic: special case for first business row:
            # output the sub-margin unless *the* *first* object is a)
            # a tag that b) we want to emphasize. (etc)

            unless :tag == o.category_symbol && :open == o.intern
              ww << ( SPACE_ * @expag.sub_margin_width )
            end

            _into_wordwrap_flush_remainder_of_object_stream ww, o, o_st
          end

          if row_st
            _into_wordwrap_flush_remainder_of_rows ww, row_st
          end

          ww.flush  # result is downstream context, i.e string

          ACHIEVED_  # this is an endpoint for some (covered)
        end

        def __from_non_head_via_object_stream row, row_st

          s = _get_ID_description

          ww = _start_word_wrap s.length

          o_st = row.to_object_stream_ row_st

          o = o_st.gets

          if o
            _into_wordwrap_flush_remainder_of_object_stream ww, o, o_st
          end

          _into_wordwrap_flush_remainder_of_rows ww, row_st

          # this method is different from the above counterpart in that
          # 1) it does not express the identifier (altho it does determine
          # the margin from its width) 2) it puts the same margin on every
          # line and 3) it does not do the emphasis hack.

          ww.flush

          NIL_
        end

        def _get_ID_description
          s = ""
          @node.ID.express_into_under s, @expag
          s
        end

        def _into_wordwrap_flush_remainder_of_rows ww, row_st

          begin
            row = row_st.gets
            row or break
            o_st = row.to_object_stream_ row_st
            o = o_st.gets
            if o
              _into_wordwrap_flush_remainder_of_object_stream ww, o, o_st
            end
            redo
          end while nil
          NIL_
        end

        def _into_wordwrap_flush_remainder_of_object_stream ww, o, o_st

          begin

            # word-wrap's job function is to put the correct whitespace
            # character (either space or newline) between each "word".
            # having our own whitespace in the input confuses this so:

            if :string == o.category_symbol

              s = o.get_string
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

          Home_.lib_.basic::String::WordWrapper::Calm.new_with(
            :downstream_yielder, y,
            :margin, margin,
            :width, @expag.width,
            :add_newlines,
            * skip_margin )

        end
      end
    end
  end
end
