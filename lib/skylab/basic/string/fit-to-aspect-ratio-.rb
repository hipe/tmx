module Skylab::Basic

  module String

    module Fit_to_Aspect_Ratio_  # notes in [#033]

      module Methods

        def flush
          flush_via_fit_ Find_Best_Fit__.
            new( @pieces, * @ratio_a ).find_best_fit
        end
      end

      class Find_Best_Fit__

        def initialize pcs, ratio_width, ratio_height
          @pieces = pcs
          @ratio_width = ratio_width
          @ratio_height = ratio_height
        end

        def find_best_fit
          __determine_total_unit_length_and_longest_nonwhite_space
          __determine_first_width_guess
          __find_best_fit
        end

        def __determine_total_unit_length_and_longest_nonwhite_space

          longest = 0
          total = 0

          @pieces.each do | piece |
            d = piece.length
            total += d
            if :non_space == piece.category_symbol && longest < d
              longest = d
            end
          end

          @longest_d = longest
          @total = total
          nil
        end

        def __determine_first_width_guess  # see note-A

          _sqrt_me = 1.0 * @total / @ratio_width / @ratio_height

          _factor = ::Math.sqrt _sqrt_me

          _width_guess = _factor * @ratio_width

          @first_width_guess = _width_guess.ceil

          if @first_width_guess < @longest_d

            # your output width will never be lower than the largest
            # width of the input content surface pieces.

            @first_width_guess = @longest_d
          end

          nil
        end

        def __find_best_fit

          @fitter = Fitter___.new @pieces, @ratio_width, @ratio_height

          @index_of_last_piece = @pieces.length - 1

          @fit = @fitter.fit_to_width @first_width_guess

          @do_look_wider = 1 < @fit.line_count

          __find_ideal_narrowest_fit

          if @do_look_wider
            __find_ideal_widest_fit
          end

          @fit
        end

        def __find_ideal_narrowest_fit

          begin

            if @longest_d == @fit.actual_width
              # you can't go narrower than the longest piece
              break
            end

            fit_ = __try_narrower @fit
            fit_ or break

            cmp = fit_.compared_against @fit

            if cmp.is_better
              @do_look_wider = false
              @fit = fit_
              if cmp.keep_looking

                redo
              end
            end
            break
          end while nil
          nil
        end

        def __find_ideal_widest_fit

          begin

            ok = __resolve_widening_pool
            ok &&= __resolve_widening_range_boundaries
            ok && __via_widening_range_boundaries_produce_ideal_fit

            # (we used to loop this search forwards. now it's just one go.)

          end while nil

          @fit
        end

        def __resolve_widening_pool

          fit = _try_wider @fit

          if fit

            pool = [ @fit, fit ]

            if 1 < fit.line_count
              fit_ = _try_wider fit
              if fit_
                pool.push fit_
              end
            end

            @widening_pool = pool
            ACHIEVED_
          end
        end

        def __resolve_widening_range_boundaries

          # find the range boundaries across two fields
          # of the adjacent two or three next fits

          pool = @widening_pool

          st = Callback_::Stream.via_nonsparse_array pool

          fit = st.gets
          d = 0

          @best_orph_idx = d
          @worst_orph_idx = d
          @best_orph_f = fit.orphanlessness
          @worst_orph_f = @best_orph_f

          @best_ratio_idx = d
          @worst_ratio_idx = d
          @best_ratio_f = fit.abs_ratio_delta
          @worst_ratio_f = @best_ratio_f

          begin
            d += 1
            fit = st.gets
            fit or break

            o_f = fit.orphanlessness
            d_f = fit.abs_ratio_delta

            if @best_orph_f < o_f
              @best_orph_f = o_f
              @best_orph_idx = d
            elsif @worst_orph_f > o_f
              @worst_orph_f = o_f
              @worst_orph_idx = d
            end

            if @best_ratio_f > d_f
              @best_ratio_f = d_f
              @best_ratio_idx = d
            elsif @worst_ratio_f < d_f
              @worst_ratio_f = d_f
              @worst_ratio_idx = d
            end

            redo
          end while nil

          ACHIEVED_
        end

        def __via_widening_range_boundaries_produce_ideal_fit

          # if the fit with the best ratio has an orphanlesness of
          # for e.g half the horizontal width or greater, just use that

          fit = @widening_pool.fetch @best_ratio_idx

          if ORPH_THRESHOLD__ <= fit.orphanlessness

            @fit = fit

          else  # let's just use the fit with the best
            # best orphanlessness and be done with it

            @fit = @widening_pool.fetch @best_orph_idx

          end
          nil
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
          # you can stop looking immediately because it won't go lower.

          lowest_width_amt = nil
          pairs = fit.line_pairs

          ( fit.line_count - 1 ).times do | pair_idx |

            pair_idx <<= 1

            width = __width_of_unused_tailspace_at_line pair_idx, fit
            width.zero? and next

            _pairs_index_of_last_piece_on_this_line = pair_idx + 1

            last_piece_on_this_line = @pieces.fetch pairs.fetch(
              _pairs_index_of_last_piece_on_this_line )

            piece_index_of_first_piece_to_add = last_piece_on_this_line.piece_index + 1

            # (we don't want the first piece on the next line, we want
            # the piece after the last piece on this line - this way,
            # in the jump we include the received whitespace.)

            pc = _ending_content_piece_to_accomodate = _first_piece_from(
              piece_index_of_first_piece_to_add, :non_space )

            pc or break

            _jump_width = ( piece_index_of_first_piece_to_add .. pc.piece_index ).reduce 0 do | m, d |
              m + @pieces.fetch( d ).length
            end

            amt_needed_to_add = _jump_width - width

            case 1 <=> amt_needed_to_add
            when  1
              next
            when 0
              lowest_width_amt = 1
              break
            end

            if ! lowest_width_amt
              lowest_width_amt = amt_needed_to_add
            elsif amt_needed_to_add < lowest_width_amt
              lowest_width_amt = amt_needed_to_add
            end
          end

          if lowest_width_amt
            _longer_width = fit.actual_width + lowest_width_amt
            @fitter.fit_to_width _longer_width
          end
        end

        def _first_piece_from d, sym
          begin
            pc = @pieces.fetch d
            if sym == pc.category_symbol
              did_find = true
              break
            end
            @index_of_last_piece == d and break
            d += 1
            redo
          end while nil
          did_find and pc
        end

        def __width_of_unused_tailspace_at_line d, fit

          a = fit.line_pairs

          _line_width = ( a.fetch( d ) .. a.fetch( d + 1 ) ).reduce 0 do | m, d_ |
            m + @pieces.fetch( d_ ).length
          end

          fit.actual_width - _line_width
        end
      end

      class Fitter___

        def initialize pieces, ratio_width, ratio_height

          @implementation = String_::Word_Wrappers__::Calm::Fit_to_Width_.new pieces

          @target_calculation = Target_Calculation___.new ratio_width, ratio_height

        end

        def fit_to_width width_d

          fit = @implementation.fit_to_width width_d
          if fit

            Calculation_of_Fit__.new fit, @target_calculation

          end
        end
      end

      class Target_Calculation___

        def initialize ratio_width, ratio_height

          @target_ratio_factor = 1.0 * ratio_width / ratio_height

        end

        attr_reader :target_ratio_factor

      end

      class Calculation_of_Fit__

        def initialize fit, target_calc

          # target_calculation.target_ratio_factor

          @actual_width = fit.actual_width
          @line_pairs = fit.line_pairs

          @line_count = @line_pairs.length / 2

          if @line_count.nonzero?

            @orphanlessness = 1.0 * fit.narrowest_line_width / @actual_width

            @actual_ratio_factor = 1.0 * @actual_width / @line_count

            @abs_ratio_delta = ( target_calc.target_ratio_factor -
              @actual_ratio_factor ).abs

          end
        end

        attr_reader :abs_ratio_delta,
         :actual_width, :line_count, :line_pairs,
          :orphanlessness

        def compared_against calc_fit

          Comparison__.new( self, calc_fit ).build_comparison
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

          @i_win, stop_looking = _tiebraker @me, @other
          @keep_looking = ! stop_looking

        end

        def __when_I_have_a_worse_ratio_but_I_am_less_orphanic

          other_wins, stop_looking = _tiebraker @other, @me
          @i_win = ! other_wins
          @keep_looking = ! stop_looking
          nil
        end

        def _tiebraker better_ratio, less_orphanic

          # true-ish means that the left one wins, else right wins

          if ORPH_THRESHOLD__ > better_ratio.orphanlessness

            # when we choose the less orphanic one over the better
            # ratio, it means a direction change (maybe?). stop
            # narrowing the search

            [ false, true ]

          else

            true
          end
        end
      end

      ORPH_THRESHOLD__ = 0.5  # when the "wasted space" of the most
        # orphanic line exceeds this share of the horizontal space,
        # give more weight to de-orphanizing it than to approaching
        # the target ratio

    end
  end
end
