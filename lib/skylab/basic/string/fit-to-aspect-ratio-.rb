module Skylab::Basic

  module String

    module Fit_to_Aspect_Ratio_  # see [#033]

      module Layout_Engine_Methods

        def init_layout_engine_

          init_tokenization_

          @_ratio_a = remove_instance_variable( :@aspect_ratio )
          @_token_o_a = []

          NIL_
        end

        def << mixed_string

          # unlike the base library counterpart, we do *no* continuous
          # flushing here because that is antithetical to the algorithm.
          # rather, we just memoize all of the contents of the tokenizer
          # buffer and do the heavy lifting in `flush`.

          @reinit_tokenizer_[ mixed_string ]

          st = @tokenizer_.step_stream

          begin
            o = st.gets
            o or break
            @_token_o_a.push o.to_token
            redo
          end while nil

          self
        end

        def flush

          ( @margin || @first_line_margin || @first_line_margin_width ) and
            self._FIT_to_aspect_ratio_cannot_currently_work_with_margins

          _fit = Find_Best_Fit___.new( @_token_o_a, * @_ratio_a ).find_best_fit

          _fit.row_array.each do | row_o |

            into_downstream_yielder_flush_these_mutable_tokens_(
              row_o.token_array )

          end

          @downstream_yielder
        end

        include String_::Word_Wrappers__::Calm::Parse_Context_Methods
      end

      class Find_Best_Fit___

        def initialize pcs, ratio_width, ratio_height

          @pieces = pcs
          @ratio_height = ratio_height
          @ratio_width = ratio_width
        end

        def find_best_fit

          __determine_total_unit_length_and_longest_word
          __determine_first_width_guess
          __find_best_fit
        end

        def __determine_total_unit_length_and_longest_word

          longest = 0
          total = 0

          @pieces.each do | piece |
            d = piece.length
            total += d
            if :word == piece.symbol && longest < d
              longest = d
            end
          end

          @longest_d = longest
          @total = total
          NIL_
        end

        def __determine_first_width_guess  # see "this formula" (#note-A)

          _sqrt_me = 1.0 * @total / @ratio_width / @ratio_height

          _factor = ::Math.sqrt _sqrt_me

          _width_guess = _factor * @ratio_width

          @first_width_guess = _width_guess.ceil

          if @first_width_guess < @longest_d

            # your output width will never be lower than the largest
            # width of the input content surface pieces.

            @first_width_guess = @longest_d
          end

          NIL_
        end

        def __find_best_fit

          @fitter = Tryer___.new @pieces, @ratio_width, @ratio_height

          @index_of_last_piece = @pieces.length - 1

          @fit = @fitter.fit_to_width @first_width_guess

          @do_look_wider = 1 < @fit.line_count

          __move_to_ideal_narrowest_fit

          if @do_look_wider
            __move_to_ideal_widest_fit
          end

          @fit
        end

        def __move_to_ideal_narrowest_fit

          begin

            if @longest_d == @fit.actual_width
              # you can't go narrower than the longest piece
              break
            end

            fit_ = __try_narrower @fit
            fit_ or break

            cmp = fit_.compared_against @fit

            _contender_is_better_than_current = cmp.is_better

            if _contender_is_better_than_current

              @do_look_wider = false
              @fit = fit_
              if cmp.keep_looking

                redo
              end
            end

            break

          end while nil

          NIL_
        end

        def __move_to_ideal_widest_fit

          best_fit = @fit

          wider = _try_wider best_fit

          if wider
            __widening_shootout wider, best_fit
          else
            best_fit
          end
        end

        def __widening_shootout wider, best_fit

          did_second_try = false

          begin

            cmp = wider.compared_against best_fit

            _contender_is_better_than_current = cmp.is_better

            if _contender_is_better_than_current

              did_second_try = false  # reset the clock on this here

              best_fit = wider

              # we found a better one. maybe keep looking in this direction

              if ! cmp.keep_looking  # it has its own reasons
                break
              end

              if 1 == best_fit.line_count  # you can't go wider than 1 line
                break
              end

              wider = _try_wider best_fit
              if wider
                redo
              end
              break
            end

            # contender lost. sometimes a 2nd try finds a better fit

            if did_second_try
              break  # else we would keep trying *many* until one line
            end

            wider_ = _try_wider wider

            if wider_
              wider = wider_
              did_second_try = true
              redo
            end

            break
          end while nil

          @fit = best_fit

          NIL_
        end

        def __try_narrower fit  # assume width is wider than etc.

          # like the widening counterpart to this method below, the goal
          # is to change the width by the minimum amount necessary to get
          # something to move. unlike below, here if we reduce the width
          # by exactly one unit, it is "guaranteed" to have the desired
          # effect because the actual width of the fit was determined by
          # the content alone: to reduce the width at all guarantees that
          # content (somewhere) no longer has enough room on that line
          # and so change is guaranteed.

          _new_width = fit.actual_width - 1

          @fitter.fit_to_width _new_width
        end

        def _try_wider fit

          # walk every transition between one and the next line looking
          # for the lowest width amount you have to add to get anything
          # to move. to use a width less than this would tautologically
          # result in the same delineation that we have now which would
          # be a waste to build. to use a width greater than this would
          # cause you to miss some ideal fits. if you find a value of 1
          # you can stop looking immediately because that's the floor.

          lowest_amt_of_width_needed_to_add = nil
          row_a = fit.row_array

          ( row_a.length - 1 ).times do | d |

            row = row_a.fetch d

            row_ = row_a.fetch d + 1

            # IFF the last token on this line and the first on the next
            # are both words in order to get the jump to happen we need
            # to add not only the width of the second word but also the
            # separator that will need to go between them. also we make
            # this assumption per our standard word-wrap algorithm: any
            # first token on a row will be a word or a "special spaces"
            # (a spaces token that is more than 1 character).

            tok = row.token_array.last
            tok_ = row_.token_array.first

            width_needed_to_make_the_jump = tok_.length

            if :word == tok.symbol && :word == tok_.symbol
              width_needed_to_make_the_jump += 1  # SPACE_.length
            end

            # if the current line was any amount of orphan (that is it
            # had more than zero "slots" of unused space at the end if
            # compared to the longest line) then the "jump" we want to
            # accomodate can use this empty space so it's less that we
            # need to add to the width to get something to move.

            _width_of_trailing_unused_space = fit.actual_width - row.width

            amt_needed_to_add = width_needed_to_make_the_jump -
              _width_of_trailing_unused_space

            case 1 <=> amt_needed_to_add
            when  1
              next
            when 0
              lowest_amt_of_width_needed_to_add = 1
              break
            end

            # (simple iterative min finder:)

            if ! lowest_amt_of_width_needed_to_add
              lowest_amt_of_width_needed_to_add = amt_needed_to_add
            elsif amt_needed_to_add < lowest_amt_of_width_needed_to_add
              lowest_amt_of_width_needed_to_add = amt_needed_to_add
            end
          end

          if lowest_amt_of_width_needed_to_add

            _longer_width = fit.actual_width +
              lowest_amt_of_width_needed_to_add

            @fitter.fit_to_width _longer_width
          end
        end
      end

      class Tryer___

        def initialize pieces, ratio_width, ratio_height

          @_target_ratio = 1.0 * ratio_width / ratio_height

          @_tox = pieces
        end

        def fit_to_width width_d

          A_Delineation_and_its_Metrics___.new( width_d, @_tox, @_target_ratio ).execute
        end
      end

      class A_Delineation_and_its_Metrics___

        # given all of the tokens and one arbitrary width, make the tokens
        # fit into the width using the standard algorithm whose module we
        # use immediately below. as we do this and once we are finished, we
        # calculate metrics intended specifically for the subject library.
        # at the end of this we make ourselves a frozen structure with the
        # results of these calculations.

        include String_::Word_Wrappers__::Calm::Streaming_Layout_Algorithm_Methods

        def initialize width, tox, trat

          @_target_ratio = trat
          @_tox = tox
          @width = width
        end

        def execute

          @actual_width = 0  # (i.e "widest width")
          @current_width_ = 0
          @line_count = 0
          @_narrowest_width = nil

          @tokens_ = []
          @row_array = []

          _st = Callback_::Stream.via_nonsparse_array @_tox
          remove_instance_variable :@_tox

          init_context_
          init_tokenizer_via_stream_ _st

          begin
            _stay = @tokenizer_.unparsed_exists
            _stay or break

            send :"at__#{ @tokenizer_.step.symbol }__token"
            redo
          end while nil

          if @tokens_.length.nonzero?
            _realize_row
          end

          remove_context_

          %i(
             @current_width_ @tokens_ @tokenizer_ @width
          ).each do | ivar |
            remove_instance_variable ivar
          end

          __calculate
        end

        def flush

          remove_trailing_spaces_
          _realize_row

          change_context_ :margin_end_
          @current_width_ = 0
          @tokens_ = []

          NIL_
        end

        def _realize_row

          row_o = Row___.new @line_count, @tokens_
          @tokens_ = nil

          d = row_o.width

          if @_narrowest_width
            if @_narrowest_width > d
              @_narrowest_width = d
            end
          else
            @_narrowest_width = d
          end

          if @actual_width < d
            @actual_width = d
          end

          @row_array.push row_o
          @line_count += 1

          NIL_
        end

        class Row___

          def initialize row_index, tox

            @row_index = row_index

            @token_array = tox

            @width = tox.reduce 0 do | d, tok |
              d + tok.length
            end
          end

          attr_reader :row_index, :token_array, :width
        end

        def __calculate

          if @line_count.nonzero?

            # how far away is our actual ratio from the target ratio? the
            # "absolute ratio delta" measures this. the lower the number,
            # the closer the match.

            @actual_ratio_factor = 1.0 * @actual_width / @line_count

              # (visible for debugging)

            @abs_ratio_delta = ( @_target_ratio - @actual_ratio_factor ).abs

            # our "orphan line" (shortest line), how short is it relative
            # to our longest line? the "orphanlessness" measures this. a
            # a score of 1.0 means we are a prefectly justified rectangle
            # (of some ratio). the closer to zero we go, the more severe
            # the visual effect of the orphan line.

            @orphanlessness = 1.0 * @_narrowest_width / @actual_width

            remove_instance_variable :@_narrowest_width
            remove_instance_variable :@_target_ratio

            freeze
          end
        end

        attr_reader :abs_ratio_delta,
         :actual_width,
         :line_count,
         :row_array,
         :orphanlessness

        def compared_against current_champion_fit

          Comparison__.new( self, current_champion_fit ).build_comparison
        end
      end

      class Comparison__

        def initialize me, other

          @me = me
          @other = other
          @keep_looking = true
        end

        def build_comparison

          @lesser_line_count, @greater_line_count =
            [ @me.line_count, @other.line_count ].sort!

          @orphanic_vector = @me.orphanlessness <=> @other.orphanlessness

            # 1 means I win because my orphanless score (0-1) is higher

          @ratio_vector = @me.abs_ratio_delta <=>
            @other.abs_ratio_delta

            # -1 means I win here because I'm closer to target ratio

          case @ratio_vector
          when  -1
            case @orphanic_vector
            when 1, 0
              __when_I_am_the_clear_winner
            when -1
              __when_I_have_a_better_ratio_but_I_am_more_orphanic
            end
          when 0
            __when_same_ratio_delta
          when  1
            case @orphanic_vector
            when -1, 0
              __when_I_am_the_clear_loser
            when 1
              __when_I_have_a_worse_ratio_but_I_am_less_orphanic
            end
          end

          Result__.new @i_win, @keep_looking
        end

        Result__ = ::Struct.new :is_better, :keep_looking

        def __when_same_ratio_delta

          case @orphanic_vector
          when -1
            @i_win = false
          when  1
            @i_win = true
          when  0

            # covered - same orphanlessness, same delta. for no
            # particular reason we chose the wider one

            case @me.actual_width <=> @other.actual_width
            when  -1
              @i_win = false
            when   1
              @i_win = true
            else
              # sh .. let notices trigger. this might be "impossible"
            end
          end
        end

        def __when_I_am_the_clear_winner

          @i_win = true  # the easy case - i win along all criteria
        end

        def __when_I_am_the_clear_loser

          @i_win = false  # the converse of above
        end

        def __when_I_have_a_better_ratio_but_I_am_more_orphanic

          if @me.orphanlessness <= ORPH_THRESHOLD__

            @i_win = false
          else
            @i_win = true
          end

          # (since we had a better ratio, keep looking)
          NIL_
        end

        def __when_I_have_a_worse_ratio_but_I_am_less_orphanic

          if @other.orphanlessness <= ORPH_THRESHOLD__

            @i_win = true
            @keep_looking = false  # if we pull this "override",
              # don't bother looking any more in this direction

          else
            @i_win = false
          end

          NIL_
        end
      end

      ORPH_THRESHOLD__ = 0.40  # when the aspect ratio of one is better
      # but the orphanlessness of the other is better, this is how we
      # resovle the "tiebraker": of the one with the worse justification,
      # if the width of the narrowest line compared to the widest line is
      # this ratio or less, then that delineation is "very orphanic" and
      # can be beaten by a worse ratio that has better orphanlessness.

    end
  end
end
