module Skylab::MetaHell

  (( FUN = ::Class.new( ::Module ).new )).const_set :Module, FUN.class

  class FUN::Module

  private

    def definer
      @definer ||= begin
        bx = box
        Aset_.new do |i, p|
          define_singleton_method i do @h.fetch i end
          bx.add i, p
        end
      end
    end

    class Aset_ < ::Proc  # (from ruby source, `rb_hash_aset` is []=)
      alias_method :[]=, :call
    end

    def box
      @box ||= Box_[ @a = [ ], @h = { } ]
    end

    Box_ = -> a, h do
      Add_.new do |i, x|
        did = false
        h.fetch i do |_|
          did = true ; a << i ; h[ i ] = x
        end
        did or raise ::KeyError, "won't clobber existing \"#{ i }\""
        x  # #{ result must be input argument in case the []= form was used }
      end
    end
    class Add_ < ::Proc
      alias_method :add, :call
    end

  public

    def members
      @a.dup
    end

    def at *a
      a.map( & @h.method( :fetch ) )
    end
  end

  module FUN

    o = definer

    o[:import] = -> to_mod, from_mod, i_a do
      i_a.each do |i|
        to_mod.const_set i, from_mod.const_get( i, false )
      end
    end

    o[:hash2struct] = -> h do     # ( the simplest, oldest way to make a FUN )
      ::Struct.new( * h.keys ).new( * h.values )
    end

    o[:memoize] = -> func do      # creates a function `func2` from `func`.
      use = -> do                 # the first time `func2` is called, it calls
        x = func.call             # `func` and stores its result in memory,
        use = -> { x }            # and also uses that result as its result.
        x                         # each subsequent time you call `func2` it
      end                         # uses that same result stored in memory from
      -> { use.call }             # the first time you called it. please be
    end                           # careful.

    o[:memoize_to_const_method] = -> p, c do  # use with `define_method`
      puff = Puff_constant_.curry[ false, -> _ { p.call }, c ]
      -> do
        puff[ self, nil ]
      end
    end
    #
    Puff_constant_ = -> do_inherit, p, c, mod, arg do  # #curry-friendly
      if mod.const_defined? c, do_inherit
        mod.const_get c
      else
        mod.const_set c, p[ arg ]
      end
    end

    o[:without_warning] = -> f do
      x = $VERBOSE; $VERBOSE = nil
      r = f.call                  # `ensure` is out of scope for now
      $VERBOSE = x
      r
    end

    o[:pathify_name] = -> const_name_s do
      # (one extra rarely-used step added to the often-used function)
      ::Skylab::Autoloader::FUN.pathify[ const_name_s.gsub( '::', '/' ) ]
    end

    # `seeded_function_chain` - given a stack of functions and one seed value,
    # resolve one result.. fuller description at [#mh-026].
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

    o[:function_chain] = -> * p_a do
      Function_chain_[ p_a, nil ]
    end

    o[:seeded_function_chain] = -> arg_x, * p_a do
      Function_chain_[ p_a, [ arg_x ] ]
    end

    Function_chain_ = -> p_a, first_arg_a do
      res_a = p_a.reduce first_arg_a do |arg_a, p|
        ok, *rest = p[ * arg_a ]
        if ok
          true == ok or rest.unshift( ok )  # "double-duty" term
          rest
        else
          break rest
        end
      end
      res_a.length < 2 ? res_a[ 0 ] : res_a
    end

    class Module  # LOOK
    private
      def predefiner
        @predefiner ||= begin
          bx = box ; mutex = MetaHell::Services::Basic::
              Mutex::Hash.new do |key, c_a, _|
            raise "circular dependence detected with `#{ key }` - are you #{
              }sure it is defined in #{ self }::#{ c_a * '::' }?"
          end
          Aset_.new do |i, c_a|
            bx.add i, c_a
            define_singleton_method i do
              mutex.hold_notify i, c_a
              c_a = @h.fetch i
              c_a.reduce self do |m, c|
                m.const_get c, false
              end
              c_a.object_id == @h.fetch( i ).object_id and raise "#{
                }#{ self }::#{ c_a * '::' } failed to redefine `#{ i }`"
              send i
            end
          end
        end
      end
   public
      def redefiner
        @redefiner ||= begin
          Aset_.new do |i, p|
           @h.key?( i ) or raise "`#{ i }` was not [pre]defined in #{ self }"
           singleton_class.send :remove_method, i
           define_singleton_method i do @h.fetch i end
           @h[ i ] = p
           p  # #{ result must be input argument in case the []= form was used }
          end
        end
      end
    end

    x = predefiner

    x[:parse_curry]                      = [ :Parse, :Curry ]
    x[:parse_series]                     = [ :Parse, :Series ]
    x[:parse_from_set]                   = [ :Parse, :From_Set ]
    x[:parse_from_ordered_set]           = [ :Parse, :From_Ordered_Set ]
    x[:parse_alternation]                = [ :Parse, :Alternation_ ]

    x[:fields]                           = [ :Fields_ ]

    x[:private_attr_reader]              =
    x[:private_attr_accessor]            =
    x[:module_defines_method_in_some_manner] = [ :Deprecated ]

  end
end
