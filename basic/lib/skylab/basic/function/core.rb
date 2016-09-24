module Skylab::Basic

  module Function

    # given a queue of functions and one seed value, produce one result
    #
    #     FUNC = Home_::Function.chain( [
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
    #
    # this short circuits at the first branch, resulting in a value
    #
    #     s = FUNC[ 'cilantro' ]
    #     s  # => 'i hate cilantro'
    #
    #
    # resulting in a single true-ish item will result in that value
    #
    #     s = FUNC[ 'carrots' ]
    #     s  # => "let's have carrots and potato"
    #
    #
    # resulting in the tuple [ false, X ] gives you X
    #
    #     s = FUNC[ 'red' ]
    #     s  # => 'nope i hate tomato'
    #
    #
    # this follows all the way through to the end with a true-ish item
    #
    #     x = FUNC[ 'blue' ]
    #     x  # => [ 'blue', 'potato' ]
    #
    #
    # Blue potato. everything should be perfectly clear now.

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
