module Skylab::MetaHell

  module Lib__

    # `function_chain` - given a stack of functions and one seed value,
    # resolve one result.. fuller description at [#026].
    #
    # opaque but comprehensive example:
    #
    #     f_a = [
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
    #       end ]
    #     s = MetaHell_.function_chain 'cilantro',  * f_a
    #     s  # => 'i hate cilantro'
    #     s = MetaHell_.function_chain 'carrots', * f_a
    #     s  # => "let's have carrots and potato"
    #     s = MetaHell_.function_chain 'red', * f_a
    #     s  # => 'nope i hate tomato'
    #     x = MetaHell_.function_chain 'blue', * f_a
    #     x  # => [ 'blue', 'potato' ]
    #
    # Blue potato. everything should be perfectly clear now.

    Function_chain = -> p_a, first_arg_a do
      res_a = p_a.reduce first_arg_a do |arg_a, p|
        ok, *rest = p[ * arg_a ]
        if ok
          true == ok or rest.unshift( ok )  # "double-duty" term
          rest
        else
          break rest
        end
      end
      if res_a.length < 2
        res_a.first
      else
        res_a
      end
    end

    Import_constants__ = -> from_mod, i_a, to_mod do
      i_a.each do |i|
        to_mod.const_set i, from_mod.const_get( i, false )
      end
    end

    Import_methods__ = -> from, i_a, priv_pub, to_mod do  # #todo-no longer used?
      to_mod.module_exec do
        i_a.each do |i|
          define_method i, & from[ i ]
        end
        :private == priv_pub and private( * i_a )
      end
      nil
    end

    Is_primitive_esque__ = -> x do
      ! x or case x
      when ::TrueClass, ::Numeric, ::Symbol, ::String, ::Module ; true
      end
    end

    Levenshtein_default_proc___ = -> d, h, k do
      raise ::KeyError, Say_not_found[ d, h.keys, k ]
    end

    A_HANDFUL_ = 5

    Levenshtein_default_proc__ = Levenshtein_default_proc___.curry[ A_HANDFUL_ ]

    Memoize_to_const_method__ = -> p, c do  # use with `define_method`
      touch = Touch_const.curry[ false, -> _ { p.call }, c ]
      -> do
        touch[ self, nil ]
      end
    end

    Say_not_found_ = -> d, a, k do

      s = MetaHell_::Lib_::Levenshtein[].with(
        :item, k,
        :items, a,
        :closest_N_items, d,
        :aggregation_proc, -> a_ { a_ * ' or ' } )

      if s
        _did_you_mean = " - did you mean #{ _s }?"
      end

      "not found #{ MetaHell_.strange k }#{ _did_you_mean }"
    end

    Say_not_found = Say_not_found_.curry[ A_HANDFUL_ ]

    Touch_const_reader = -> do_inherit, create_p, c, mod, arg do
      p = Touch_const.curry[ do_inherit, create_p, c, mod ]
      -> { p[ arg ] }
    end

    Touch_const = -> do_inherit, create_p, c, mod, create_arg_x do  # :+#curry-friendly
      if mod.const_defined? c, do_inherit
        mod.const_get c
      else
        mod.const_set c, create_p[ create_arg_x ]
      end
    end

    Without_warning__ = -> p do
      x = $VERBOSE; $VERBOSE = nil
      r = p.call  # `ensure` is out of scope for now
      $VERBOSE = x
      r
    end
  end
end
