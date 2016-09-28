module Skylab::Basic

  module Function

    # compose a "function chain" with a list of functions:
    #
    #     func = Home_::Function.chain( [
    #       -> item do
    #         if 'cilantro' == item            # the true-ishness of the 1st
    #           [ false, 'i hate cilantro' ]   # element in the result tuple
    #         else                             # determines short circuit
    #           [ true, item, ( 'red' == item ? 'tomato' : 'potato' ) ]
    #         end                              # three above becomes two
    #       end, -> item1, item2 do            # here, b.c the 1st is
    #         if 'carrots' == item1            # discarded when true
    #           "let's have carrots and #{ item2 }" # note no tuple necessary
    #         elsif 'tomato' == item2          # if it's just one true-ish
    #           [ false, 'nope i hate tomato' ]  # non-true item
    #         else
    #           [ item1, item2 ]
    #         end
    #       end,
    #     ] )
    #
    # normally each component function's result is treated as a "tuple"
    # (array) where the first element of that tuple is treated as a boolean
    # indicating whether or not to continue along on the chain of functions
    # (true-ish means "yes" and false-ish means "no"), and any remaining
    # elements in the tuple at offset 1 thru N-1 will either be used as
    # arguments to pass to the next function, or the final result as
    # appropriate.
    #
    # given the below argument, the *first* function results in a tuple whose
    # first element is `false` (which means "don't keep going"); so the final
    # result of the call is that second element of the tuple:
    #
    #     func[ 'cilantro' ]  # => "i hate cilantro"
    #
    # otherwise, when (as with the argument in the next example) the first
    # tuple element is trueh-ish, it means "keep going", and the elements at
    # offsets 1 thru N-1 of that tuple are passed as arguments to the next
    # function in the chain.
    #
    # if the result of the component function does not look like a tuple
    # (array), this value (whatever it is) is used as the final result of
    # the chain call:
    #
    #     func[ 'carrots' ]  # => "let's have carrots and potato"
    #
    # the above is shorthand for resulting in `[ false-ish, X ]` which
    # (since its first element is falseish) is an indication that the final
    # result (`X`) has been found:
    #
    #     func[ 'red' ]  # => "nope i hate tomato"
    #
    # if you are at the last function and you result in what looks like a
    # tuple that expresses "keep going", there is no next function to keep
    # going. for now, the result is just the tuple as-is:
    #
    #     func[ 'blue' ]  # => %w( blue potato )

    class << self

      def chain p_a
        Function_chain___[ p_a ]
      end

      def globful_actor cls

        cls.class_exec do
          define_singleton_method :[], GLOBFUL_CALL_METHOD__
          define_singleton_method :call, GLOBFUL_CALL_METHOD__
        end
        NIL_
      end

      def globless_actor cls

        cls.class_exec do
          define_singleton_method :[], GLOBLESS_CALL_METHOD__
          define_singleton_method :call, GLOBLESS_CALL_METHOD__
        end
        NIL_
      end
    end  # >>

    GLOBFUL_CALL_METHOD__ = -> * x_a do
      new( * x_a ).execute
    end

    GLOBLESS_CALL_METHOD__ = -> * x_a do
      new( x_a ).execute
    end

    Function_chain___ = -> p_a do  # see [#047]

      -> * arg_a do

        x_a = p_a.reduce arg_a do | arg_a_, p |

          ok_x, * x_a_ = p[ * arg_a_ ]
          if ok_x

            if true != ok_x  # hackish double-duty term
              x_a_.unshift ok_x
            end
            x_a_
          else
            break x_a_
          end
        end

        if 2 > x_a.length
          x_a[ 0 ]  # not fetch
        else
          x_a
        end
      end
    end
  end
end
