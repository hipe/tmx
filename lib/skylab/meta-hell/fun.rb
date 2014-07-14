module Skylab::MetaHell

  (( FUN = ::Class.new( ::Module ).new )).const_set :Module, FUN.class

  Fun = FUN  # :+[#cb-027]

  module FUN
    LIB = class Lib__
      def struct_from_hash h
        # ( the simplest, oldest way to make a FUN )
        ::Struct.new( * h.keys ).new( * h.values )
      end
      self
    end.new
  end

  class FUN::Module

  private

    def definer
      @definer ||= begin
        bx = box
        Aset__.new do |i, p|
          define_singleton_method i do @h.fetch i end
          bx.add i, p
        end
      end
    end

    class Aset__ < ::Proc  # (from ruby source, `rb_hash_aset` is []=)
      alias_method :[]=, :call
    end

    def box
      @box ||= Box__[ @a = [ ], @h = { } ]
    end

    Box__ = -> a, h do
      Add__.new do |i, x|
        did = false
        h.fetch i do |_|
          did = true ; a << i ; h[ i ] = x
        end
        did or raise ::KeyError, "won't clobber existing \"#{ i }\""
        x  # #{ result must be input argument in case the []= form was used }
      end
    end
    class Add__ < ::Proc
      alias_method :add, :call
    end

  public

    def members
      @a.dup
    end

    def at *a
      a.map( & @h.method( :fetch ) )
    end

    def constants_at * i_a
      i_a.map do |i|
        const_get i, false
      end
    end

    def each_pair &p
      ech_pr_for_a_and_p @a, p
    end

    def each_pair_at i_a, & p
      ech_pr_for_a_and_p i_a, p
    end
  private
    def ech_pr_for_a_and_p i_a, p
      ea = ::Enumerator.new do |y|
        i_a.each do |i|
          y.yield i, @h.fetch( i )
        end ; nil
      end
      p ? ea.each( & p ) : ea
    end
  end

  module FUN

    o = definer

    Import_constants = -> from_mod, i_a, to_mod do
      i_a.each do |i|
        to_mod.const_set i, from_mod.const_get( i, false )
      end
    end

    Import_methods = -> from, i_a, priv_pub, to_mod do  # #todo-no longer used?
      to_mod.module_exec do
        i_a.each do |i|
          define_method i, & from[ i ]
        end
        :private == priv_pub and private( * i_a )
      end
      nil
    end

    Memoize = -> p do  # create a proc (suitable for use in 'define_method')
      # that, any first time you call it, its result will be the result of
      # a call to proc 'p'. any subsequent call to this proc will also be
      # that same result from the first time you called it. be careful.
      p_ = -> do
        x = p.call ; p_ = -> { x } ; x
      end
      -> { p_.call }
    end

    o[ :memoize ] = Memoize

    o[:memoize_to_const_method] = -> p, c do  # use with `define_method`
      touch = Touch_constant_.curry[ false, -> _ { p.call }, c ]
      -> do
        touch[ self, nil ]
      end
    end
    #
    Touch_constant_ = -> do_inherit, p, c, mod, arg do  # #curry-friendly
      if mod.const_defined? c, do_inherit
        mod.const_get c
      else
        mod.const_set c, p[ arg ]
      end
    end
    # ~
    Touch_constant_reader_ = -> do_inherit, p, c, mod, arg do
      p = Touch_constant_.curry[ do_inherit, p, c, mod ]
      -> { p[ arg ] }
    end

    def self.without_warning & p
      p or raise "old form is deprectated - update this to use block not proc"
      Without_warning__[ p ]
    end

    Without_warning__ = -> p do
      x = $VERBOSE; $VERBOSE = nil
      r = p.call  # `ensure` is out of scope for now
      $VERBOSE = x
      r
    end

    Is_primitive_esque = -> x do
      ! x or case x
      when ::TrueClass, ::Numeric, ::Symbol, ::String, ::Module ; true
      end
    end

    Say_not_found_ = -> d, a, k do
      _s = MetaHell_::Library_::Headless::NLP::EN::Levenshtein::
        Or_with_closest_n_items_to_item[ d, a, k ]
      "not found #{ MetaHell_::Library_::Basic::FUN::Inspect[ k ] } - #{
        }did you mean #{ _s }?"
    end

    A_HANDFUL__ = 5

    Say_not_found = Say_not_found_.curry[ A_HANDFUL__ ]

    Levenshtein_default_proc_ = -> d, h, k do
      raise ::KeyError, Say_not_found_[ d, h.keys, k ]
    end

    Levenshtein_default_proc = Levenshtein_default_proc_.curry[ A_HANDFUL__ ]

    # `seeded_function_chain` - given a stack of functions and one seed value,
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

      def initialize
        @index_of_next_flush_names = 0  # (not built for this node)
      end
      def predefiner
        @predefiner ||= begin
          bx = box ; mutex = MetaHell_::Library_::Basic::
              Mutex::Hash.new do |key, c_a, _|
            raise "circular dependence detected with `#{ key }` - are you #{
              }sure it is defined in #{ self }::#{ c_a * '::' }?"
          end
          Aset__.new do |i, c_a|
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
          Aset__.new do |i, p|
           @h.key?( i ) or raise "`#{ i }` was not [pre]defined in #{ self }"
           singleton_class.send :remove_method, i
           define_singleton_method i do @h.fetch i end
           @h[ i ] = p
           p  # #{ result must be input argument in case the []= form was used }
          end
        end
      end
      def flush_names
        if (( idx = @index_of_next_flush_names )) < (( len = @a.length ))
          @a[ idx ... len ]
        end
      end
      def [] i
        @h.fetch i
      end
    end

    x = predefiner

    x[:parse_series]                     = [ :Parse, :Series ]
    x[:parse_from_set]                   = [ :Parse, :From_Set ]
    x[:parse_from_ordered_set]           = [ :Parse, :From_Ordered_Set ]
    x[:parse_alternation]                = [ :Parse, :Alternation_ ]

    x[:private_attr_reader]              =
    x[:private_attr_accessor]            =
    x[:module_defines_method_in_some_manner] = [ :Deprecated ]

  end
end
