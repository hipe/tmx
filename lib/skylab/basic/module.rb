module Skylab::Basic

  module Module

    class << self

      def chain_via_module mod
        Chain_via_parts__[ mod.name.split CONST_SEP_ ]
      end

      def chain_via_parts s_a
        Chain_via_parts__[ s_a ]
      end

      def members
        singleton_class.public_instance_methods( false ) - [ :members ]
      end

      def mutex *a
        if a.length.zero?
          Mutex__
        else
          Mutex__.call_via_arglist a
        end
      end

      def touch_value_via_relative_path mod, path, create_p
        o = Touch__.new mod
        o.create_p = create_p
        o.relative_path = path
        o.execute
      end

      def value_via_parts i_a, & p
        if p
          o = Touch__.new ::Object
          o.else_p = p
          o.relative_path_parts = i_a
          o.execute
        else
          Callback_::Module_path_value_via_parts[ i_a ]
        end
      end

      def value_via_module_and_relative_parts mod, const_x_a
        o = Touch__.new mod
        o.relative_path_parts = const_x_a
        o.execute
      end

      def value_via_parts_and_relative_path prts, path_s
        o = Touch__.new
        o.starting_module_parts = prts
        o.relative_path = path_s
        o.execute
      end

      def value_via_relative_path mod, path
        o = Touch__.new mod
        o.relative_path = path
        o.execute
      end
    end  # >>

    Chain_via_parts__ = -> s_a do
      _Pair = Callback_::Pair
      pair_a = ::Array.new s_a.length
      mod = ::Object
      s_a.each_with_index do |s, d|
        mod = mod.const_get s, false
        pair_a[ d ] = _Pair.new( mod, s.intern )
      end
      pair_a
    end

    class Touch__

      def initialize starting_mod=nil
        @create_p = @else_p = nil
        @starting_module = starting_mod
        @starting_module_parts = nil
      end

      attr_writer :create_p, :else_p,
        :relative_path_parts, :starting_module_parts

      def relative_path= s
        @relative_path_parts = s.split( PATH_SEP_RX__ ) ; nil
      end

      def execute
        @normal_path_parts = build_normal_path_parts
        via_normal_path_parts_execute
      end

    private

      def build_normal_path_parts
        real_parts = if @starting_module_parts
          @starting_module_parts.dup
        elsif ::Object == @starting_module   # not necessary, just algorithmic aesthetic
          []
        else
          @starting_module.name.split CONST_SEP_
        end
        Basic_::Pathname.expand_real_parts_by_relative_parts real_parts, @relative_path_parts, CONST_SEP_
      end

      def via_normal_path_parts_execute
        m = ::Object ; path_a = @normal_path_parts
        d = -1 ; last = path_a.length - 1
        while d != last
          d += 1
          s = path_a.fetch d
          if m.const_defined? s, false
            x = m.const_get s, false
            m = x
          elsif @create_p and last == d
            x = m.const_set s, @create_p.call  # #experimental: signature may change
            break
          elsif @else_p
            x = @else_p[ s, m ]
            m = x  # KEEP GOING covered.
          else
            x = m.const_get s, false  # trigger the error or trip a.l
            m = x
          end
        end
        x
      end
    end

    class Mutex__  #storypoint-55

      Callback_::Actor.call self, :properties,
        :method_name,
        :proc

      def process_arglist_fully a
        process_arglist_fully_with_args( * a )
      end

      def process_arglist_fully_with_args method_name=nil, p
        @method_name = method_name
        @proc = p ; nil
      end

      def execute
        actor = self
        mut_h = {}
        p = @proc
        -> *a do  # assume self is a client module
          d = object_id
          did = x = nil
          mut_h.fetch d do
            mut_h[ d ] = did = true
            x = module_exec( *a, & p )
          end
          if did
            x
          else
            raise actor.say_failure self
          end
        end
      end

      def say_failure mod
        if @method_name
          "module mutex failure - cannot call `#{ @method_name }` more #{
          }than once on a #{ mod }"
        else
          "module mutex failure - #{ mod }"
        end
      end
    end

    CONST_SEP_ = '::'.freeze
    PATH_SEP_RX__ = %r(::|/)

    Module_ = self
  end
end
