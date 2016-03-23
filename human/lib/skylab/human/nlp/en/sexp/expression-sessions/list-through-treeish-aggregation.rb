module Skylab::Human

  module NLP::EN::Sexp

    class Expression_Sessions::List_through_Treeish_Aggregation

      # (see comments below re: algorithm)

      class << self

        def expression_via_sexp_stream_ st
          st.assert_empty
          new
        end

        alias_method :begin, :new

        private :new
      end  # >>

      def initialize
        # (make this dup safe for now..)
        @_m = :_add_first_expression
      end

      def initialize_copy _
        @_m = :_add_first_expression
        @_a = nil ; @_bx = nil
      end

      def add_sexp sx

        _ = EN_::Sexp.expression_session_via_sexp sx
        ___add_expression _
      end

      def ___add_expression exp
        send @_m, exp
      end

      def _add_first_expression exp

        # (for dup safety, we don't initialize our main data til now)
        @_a = []
        @_bx = Callback_::Box.new
        @_m = :___add_subsequent_expression
        _add_new_record_and_index exp
        NIL_
      end

      def ___add_subsequent_expression exp

        d_a = @_bx[ exp.association_symbol_ ]
        if d_a
          ___aggregate_into_existing_or_add_new d_a, exp
        else
          _add_new_record_and_index exp
        end
      end

      def ___aggregate_into_existing_or_add_new d_a, exp_

        did = false
        d_a.each do |d|
          exp = @_a.fetch d
          did = Assimilate[ exp, exp_ ]
          did and break
        end
        if ! did
          _add_new_record_and_index exp_
        end
      end

      def _add_new_record_and_index exp
        d = @_a.length
        @_bx.touch_array_and_push exp.association_symbol_, d
        @_a[ d ] = exp
        NIL_
      end

      # --

      def expression_via_finish

        # (we don't actually mutate but the method name is future-proofed towards this)

        if 1 == @_a.length
          @_a.fetch 0
        else
          Siblings_::Predicateish::List.via_ @_a
        end
      end

      class Assimilate

        # this is a reconception of what we're calling [#002], whose sibling
        # in this universe dates back to may 2013, but whose theory we
        # developed in the late 90's (..). but we have made this "tree based"
        # (and perhaps recursive) instead of "column based", so the algorithm
        # is not concerned with (and does not support) contiguous *columns"
        # that are aggregatable, but rather it tries to find (somehow) only
        # one component that is aggregatable (and the left of those components
        # might aggregate recursively..)

        class << self

          def [] exp, exp_  # result in t/f (did/didn't do)

            # for each formal component according to the outside expression..

            atrs = exp.class::COMPONENTS  # ..

            is_alias = atrs.is_X( :_referrant_ ) || MONADIC_EMPTINESS_
            is_atomic = atrs.is_X( :_atomic_ ) || MONADIC_EMPTINESS_

            st = atrs.to_defined_attribute_stream

            stay = true
            compare = nil

            begin
              atr = st.gets
              atr or break

              if is_alias[ atr ]  # skip assocs that are aliases for other assocs
                redo
              end

              k = atr.name_symbol

              x = if exp.respond_to? k  # allow inside to be structural subset
                exp.send k
              end

              x_ = exp_.send k  # :#spot-3

              if is_atomic[ k ]

                # non-smart components don't have smarts for aggregation:
                # if one's nil, the other must be nil (effectively unknown)
                # if one's false, the other must be false, etc.

                if x == x_
                  redo
                end
                stay = false ; break
              end

              # they must both be set or both be not set ..

              if x
                if x_
                  if x_._can_aggregate_
                    ( compare ||= [] ).push [ x_, x, atr ]
                    redo
                  end
                end
                stay = false ; break
              elsif x_
                # outside is set but inside is not set. cannot aggregate.
                stay = false ; break
              end
              # neither is set. procede as if this formal didn't exist.
              redo
            end while nil

            if stay
              if compare
                # having gotten this far is a cause to descend..
                new( compare, exp ).execute
              else

                # this means we got through all the formals and they were all
                # either identical atom-ishes or effectively unknown..
                # we want to cover this because it means drop this entire
                # expression for being redundant..

                self._COVER_ME_probably_OK
                ACHIEVED_
              end
            else
              UNABLE_
            end
          end

          private :new
        end  # >>

        def initialize compare_a, exp
          @_compare_a = compare_a
          @_exp = exp
        end

        def execute

          if 1 == @_compare_a.length
            _maybe_assimilate( * remove_instance_variable( :@_compare_a ).fetch( 0 ) )
          else
            ___tiebreak
          end
        end

        def ___tiebreak  # see [#002]:"how we tiebreak"

          # to summarize, IFF you find exactly one "column" that is
          # "different", attempt to aggregate on this column..

          found_only_one_that_is_different = false
          the_one = nil

          @_compare_a.each do |ex_, ex, asc|

            # we let the outside one be the custodian of the method, for
            # shenanigans

            _is_same = ex_._is_equivalent_to_counterpart_ ex
            if _is_same
              next
            end

            if found_only_one_that_is_different
              self._COVER_ME_you_cannot_aggregate
            end

            found_only_one_that_is_different = true
            the_one = [ ex_, ex, asc ]
          end

          if found_only_one_that_is_different

            _maybe_assimilate( * the_one )
          else
            self._B_fine_easy
            NOTHING_
          end
        end

        def _maybe_assimilate subex_, subex, asc

          noof = subex._aggregate_ subex_
          if noof

            # we know *something* happened. did receiver mutate or did it
            # change? for now we just determine this "directly":

            if ! noof.equal? subex  # same object?
              # for now:
              @_exp.instance_variable_set asc.as_ivar, noof
            end
            ACHIEVED_
          else
            noof
          end
        end
      end

      UNABLE_ = false
    end
  end
end
