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

  o[:require_subproduct] = -> const_i do
    if ! ::Skylab.const_defined? const_i, false
      require "skylab/#{ ::Skylab::Autoloader::Inflection::FUN.
        pathify[ const_i ] }/core"
    end
    ::Skylab.const_get const_i, false
  end

  o[:require_stdlib] = -> const_i do
    require const_i.downcase.to_s
    ::Object.const_get const_i
  end

  o[:pathify_name] = -> const_name_s do
    ::Skylab::Autoloader::Inflection::FUN.
      pathify[ const_name_s.gsub( '::', '/' ) ]
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

  x = FUN_.x
  x[:parse_curry]                      = [ :Parse, :Curry ]
  x[:parse_series]                     = [ :Parse, :Series ]
  x[:parse_from_set]                   = [ :Parse, :From_Set ]
  x[:parse_from_ordered_set]           = [ :Parse, :From_Ordered_Set ]


  x[:fields]                           = [ :Fields_ ]

  def FUN.at *a
    a.map( & method( :send ) )
  end

end
