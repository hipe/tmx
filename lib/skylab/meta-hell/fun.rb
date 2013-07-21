module Skylab::MetaHell

  o = { }

  o[:import] = -> to_mod, from_mod, i_a do
    i_a.each do |i|
      to_mod.const_set i, from_mod.const_get( i, false )
    end
  end

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
    r = f.call                  # `ensure` is out of scope for now
    $VERBOSE = x
    r
  end

  o[:pathify_name] = -> const_name_s do
    ::Skylab::Autoloader::FUN.
      pathify[ const_name_s.gsub( '::', '/' ) ]
  end

  # `seeded_function_chain` - given a stack of functions and one seed value,
  # resolve one result.. fuller description at [#mh-026].
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
  #     s = MetaHell::FUN.seeded_function_chain[ 'cilantro',  * f_a ]
  #     s  # => 'i hate cilantro'
  #     s = MetaHell::FUN::seeded_function_chain[ 'carrots', * f_a ]
  #     s  # => "let's have carrots and potato"
  #     s = MetaHell::FUN.seeded_function_chain[ 'red', * f_a ]
  #     s  # => 'nope i hate tomato'
  #     x = MetaHell::FUN.seeded_function_chain[ 'blue', * f_a ]
  #     x  # => [ 'blue', 'potato' ]
  #
  # Blue potato. everything should be perfectly clear now.

  fc = -> f_a, first_arg_a do
    res_a = f_a.reduce first_arg_a do |arg_a, f|
      ok, *rest = f[ * arg_a ]
      if ok
        true == ok or rest.unshift( ok )  # "double-duty" term
        rest
      else
        break rest
      end
    end
    res_a.length < 2 ? res_a[ 0 ] : res_a
  end

  o[:function_chain] = -> * f_a do
    fc[ f_a, nil ]
  end

  o[:seeded_function_chain] = -> arg_x, *f_a do
    fc[ f_a, [ arg_x ] ]
  end

  enhance_fun_with_stowaways = -> klass, object do  # interface is #experimental
    klass.class_exec do
      @mutex_h = { }
      @subnode_location_h = { }
      @dir_pathname_p = -> { object.dir_pathname }
      @x = -> i, i_a do
        @subnode_location_h[ i ] = i_a
        define_method i do
          self.class.load_the_proc i
          send i
        end
      end
      class << @x
        alias_method :[]=, :[]
      end
      class << self
        attr_reader :x, :o
      end
      define_singleton_method :load_the_proc do |func_i|
        i_a = @subnode_location_h.fetch func_i
        (( @mutex_h.fetch( func_i ) { |k| @mutex_h[k] = true ; nil } )) and
          raise "circular dependency detected with `#{ func_i }` - are you #{
           }sure it is defined here? - #{ object }::#{ i_a * '::' }"
        i_a.reduce object do |m, i|
          m.const_get i, false
        end
        nil
      end
      @o = -> i, p do
        remove_method i if method_defined? i  # some sub-nodes add api private functions
        define_method i do p end
        nil
      end
      class << @o
        def []= i, p
          self[ i, p ]
          p
        end
      end
    end
    nil
  end

  alf = o[:autoloadize_fun] = -> oo do
    kls = ::Class.new ::Module
    kls.class_exec do
      oo.each do |k, v|
        define_method k do v end
      end
    end
    obj = kls.new
    enhance_fun_with_stowaways[ kls, obj ]
    [ obj, kls ]
  end

  FUN, FUN_ = alf[ o ]

  FUN::Fc_ = fc

  x = FUN_.x
  x[:parse_curry]                      = [ :Parse, :Curry ]
  x[:parse_series]                     = [ :Parse, :Series ]
  x[:parse_from_set]                   = [ :Parse, :From_Set ]
  x[:parse_from_ordered_set]           = [ :Parse, :From_Ordered_Set ]

  x[:fields]                           = [ :Fields_ ]

  x[:private_attr_reader]              = deprecated = [ :Deprecated ]
  x[:private_attr_accessor]            = deprecated
  x[:module_defines_method_in_some_manner] = deprecated

  def FUN.at *a
    a.map( & method( :send ) )
  end

end
