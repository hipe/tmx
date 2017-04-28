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

      def touch_const * a

        Touch_const[ * a ]
      end

      def touch_value_via_relative_path mod, path, create_p
        Touch__.call_by do |o|
          o.relative_path = path
          o.starting_module = mod
          o.create_proc = create_p
        end
      end

      def value_via_parts sym_a, & p
        if p
          Touch__.call_by do |o|
            o.relative_path_parts = sym_a
            o.starting_module = ::Object
            o.else_proc = p
          end
        else
          Common_::Const_value_via_parts[ sym_a ]
        end
      end

      def value_via_module_and_relative_parts mod, const_x_a
        Touch__.call_by do |o|
          o.relative_path_parts = const_x_a
          o.starting_module = mod
        end
      end

      def value_via_parts_and_relative_path prts, path_s
        Touch__.call_by do |o|
          o.relative_path = path_s
          o.starting_module_parts = prts
        end
      end

      def value_via_relative_path mod, path
        Touch__.call_by do |o|
          o.relative_path = path
          o.starting_module = mod
        end
      end
    end  # >>

    Chain_via_parts__ = -> s_a do

      pair_a = ::Array.new s_a.length

      mod = ::Object
      _Pair = Common_::Pair

      s_a.each_with_index do |s, d|
        mod = mod.const_get s, false
        pair_a[ d ] = _Pair.via_value_and_name( mod, s.intern )
      end

      pair_a
    end

    Touch_const = -> do_inherit, create_p, c, mod, create_arg_x do  # :+#curry-friendly
      if mod.const_defined? c, do_inherit
        mod.const_get c
      else
        mod.const_set c, create_p[ create_arg_x ]
      end
    end

    class Touch__ < Common_::MagneticBySimpleModel

      def initialize
        @create_proc = nil
        @else_proc = nil
        @starting_module = nil
        @starting_module_parts = nil
        super
      end

      def relative_path= s
        @relative_path_parts = s.split PATH_SEP_RX__ ; nil
      end

      attr_writer(
        :create_proc,
        :else_proc,
        :relative_path_parts,
        :starting_module,
        :starting_module_parts,
      )

      def execute
        @normal_path_parts = __build_normal_path_parts
        __via_normal_path_parts_execute
      end

      def __build_normal_path_parts

        _real_parts = if @starting_module_parts
          @starting_module_parts.dup
        elsif ::Object == @starting_module   # not necessary, just algorithmic aesthetic
          []
        else
          @starting_module.name.split CONST_SEP_
        end

        Home_::Pathname.expand_real_parts_by_relative_parts(
          _real_parts, @relative_path_parts, CONST_SEP_ )
      end

      def __via_normal_path_parts_execute
        m = ::Object ; path_a = @normal_path_parts
        d = -1 ; last = path_a.length - 1
        while d != last
          d += 1
          s = path_a.fetch d
          if m.const_defined? s, false
            x = m.const_get s, false
            m = x
          elsif @create_proc and last == d
            x = m.const_set s, @create_proc.call  # #experimental: signature may change
            break
          elsif @else_proc
            x = @else_proc[ s, m ]
            m = x  # KEEP GOING covered.
          else
            x = m.const_get s, false  # trigger the error or trip a.l
            m = x
          end
        end
        x
      end
    end

    class Mutex__  # #storypoint-55

      Attributes_actor_.call( self,
        :method_name,
        :proc,
      )

      def process_arglist_fully a
        process_arglist_fully_with_args( * a )
      end

      def process_arglist_fully_with_args method_name=nil, p
        @method_name = method_name
        @proc = p
        ACHIEVED_
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

    # ==

    Here_ = self  # 1x
    PATH_SEP_RX__ = %r(::|/)

    # ==
    # ==
  end
end
