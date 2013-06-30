module Skylab::MetaHell

  o = { }

  o[:hash2instance] = -> h do  # (this is here for symmetry with the below
    MetaHell::Proxy::Ad_Hoc[ h ]  # but it somewhat breaks the spirit of FUN)
  end                          # although have a look it's quite simple

  o[:hash2struct] = -> h do
    s = ::Struct.new(* h.keys ).new ; h.each { |k, v| s[k] = v } ; s
  end                           # ( for posterity this is left intact but
                                # we do this a simpler way now )

  o[:memoize] = -> func do      # creates a function `func2` from `func`.
    use = -> do                 # the first time `func2` is called, it calls
      x = func.call             # `func` and stores its result in memory,
      use = -> { x }            # and also uses that result as its result.
      x                         # each subsequent time you call `func2` it
    end                         # uses that same result stored in memory from
    -> { use.call }             # the first time you called it. please be
  end                           # careful.

  o[:without_warning] = -> f do
    x = $VERBOSE; $VERBOSE = nil
    r = f.call                   # `ensure` is out of scope for now
    $VERBOSE = x
    r
  end

  o[:require_quietly] = -> s do   # load a library that is not warning friendly
    o[:without_warning][ -> { require s } ]
  end

  # `tuple_tower` - given a stack of functions and one seed value, resolve
  # one result.. fuller description at [#fa-026].
  #
  # opaque but comprehensive example:
  #
  #     f_a = [
  #       -> item do
  #         if 'cilantro' == item                 # the true-ishness of the 1st
  #           [ false, 'i hate cilantro' ]        # element in the result tuple
  #         else                                  # determines short circuit
  #           [ true, item, ( 'red' == item ? 'tomato' : 'potato' ) ]
  #         end                                   # three above becomes two
  #       end, -> item1, item2 do                 # here, b.c the 1st is
  #         if 'carrots' == item1                 # discarded when true
  #           "let's have carrots and #{ item2 }" # note no tuple necessary
  #         elsif 'tomato' == item2               # if it's just one true-ish
  #           [ false, 'nope i hate tomato' ]     # non-true item
  #         else
  #           [ item1, item2 ]
  #         end
  #       end ]
  #     s = MetaHell::FUN.tuple_tower[ 'cilantro',  * f_a ]
  #     s # => 'i hate cilantro'
  #     s = MetaHell::FUN::tuple_tower[ 'carrots', * f_a ]
  #     s # => "let's have carrots and potato"
  #     s = MetaHell::FUN.tuple_tower[ 'red', * f_a ]
  #     s # => 'nope i hate tomato'
  #     x = MetaHell::FUN.tuple_tower[ 'blue', * f_a ]
  #     x # => [ 'blue', 'potato' ]
  #
  # Blue potato. everything should be perfectly clear now.

  o[:tuple_tower] = -> args1, *f_a do
    f_a.reduce args1 do |args, f|
      a = [ * f[ * args ] ]  # normalizes
      tf = a.fetch 0
      if tf
        a.shift if true == tf
        1 == a.length ? a[ 0 ] : a
      else
        a.shift if false == tf
        break( 1 == a.length ? a[ 0 ] : a )
      end
    end
  end

  o[:_enhance_fun_with_autoloading] = -> klass, object do  # interface is #experimental
    klass.class_exec do
      @subnode_path_h = { }
      @dir_pathname_p = -> { object.dir_pathname }
      @x = -> i, path do
        @subnode_path_h[ i ] = path
        define_method i do
          self.class.load_function i
          send i
        end
      end
      class << @x
        alias_method :[]=, :[]
      end
      class << self
        attr_reader :x, :o
        def load_function i
          load @dir_pathname_p.call.join( @subnode_path_h.fetch( i ) ).
            sub_ext( ::Skylab::Autoloader::EXTNAME ).to_s
          nil
        end
      end
      @o = -> i, p do
        remove_method i if method_defined? i  # some sub-nodes add api private functions
        define_method i do p end
        nil
      end
      class << @o
        alias_method :[]=, :[]
      end
    end
    nil
  end

  FUN = ( FUN_ = ::Struct.new( * o.keys ) ).new( * o.values )
  o[:_enhance_fun_with_autoloading][ FUN_, FUN ]

  x = FUN_.x
  x[:parse_series]           = 'parse/series'
  x[:_parse_series]          = 'parse/series'
  x[:parse_from_set]         = 'parse/from-set'
  x[:parse_from_ordered_set] = 'parse/from-ordered-set'

end
