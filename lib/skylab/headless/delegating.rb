module Skylab::Headless

  module Delegating  # read [#060] the .. narrative #storypoint-025 intro.

    def self.[] mod, * x_a
      mod.module_exec x_a, & to_proc
      x_a.length.zero? or raise ::ArgumentError, "unexpected #{
        }#{ Headless::FUN::Inspect[ x_a[ 0 ] ] }" ; nil
    end

    to_proc = -> x_a=nil do
      if x_a and x_a.length.nonzero?
        Headless::Bundles__::Delegating::Absorb_Passivley[ x_a, self ]
      else
        module_exec( & Init_as_reflective_delegating_client__ )
      end ; nil
    end ; define_singleton_method :to_proc do to_proc end

    Init_as_reflective_delegating_client__ = -> do
      if ! const_defined? :DELEGATING_MEMBER_I_A__, false
        const_set :DELEGATING_MEMBER_I_A__, []  # 1 of 2
      end
      extend MM__ ; include IM__ ; nil
    end

    module MM__

      def has_delegated_member? i
        self::DELEGATING_MEMBER_I_A__.include? i
      end

      def members
        self::DELEGATING_MEMBER_I_A__.dup
      end

      def inherited otr
        _a = otr::DELEGATING_MEMBER_I_A__.dup
        otr.const_set :DELEGATING_MEMBER_I_A__, _a  # 2 of 2
      end

   private

      def delegate * i_a
        builder = WHEN_ONE_DELEGATEE__
        i_a.each do |i|
          accpt_delegated_method i, builder.build_method( i )
        end ; nil
      end

      def delegating * x_a
        begin
          pi = Delegating_Phrase_Interpreter.new x_a
          pi.interpret_some_delegating_phrase
          bldr = pi.resolve_some_builder
          pi.resolve_some_method_name_a.each do |i|
            accpt_delegated_method i, bldr.build_method( i )
          end
        end while x_a.length.nonzero? ; nil
      end

      def accpt_delegated_method i, p
        const_get( :DELEGATING_MEMBER_I_A__, false ) << i
        define_method i, p ; nil
      end
    end  # MM__

    class Phrase_Interpreter
      def initialize x_a=nil
        @white_p ||= singleton_class.white_p
        @x_a = x_a
        super()
      end
      def self.white_p
        -> i do
          i.respond_to? :id2name and
            private_method_defined?( m = :"#{ i }=" ) and m
        end
      end
      def absorb_any_sub_phrases
        did = false
        while (( m_i = @white_p[ @x_a.first ] ))
          did ||= true
          @x_a.shift
          send m_i
          @x_a.length.zero? and break
        end
        did
      end
    end

    class Delegating_Phrase_Interpreter < Phrase_Interpreter
      def initialize x_a
        @for_single_method = @if_p = @name_p = @receiver_x_i = nil
        super
      end
      def interpret_some_delegating_phrase
        absorb_any_sub_phrases
        absrb_some_method_name_or_names
      end
      def interpret_any_delegating_phrase  # #storypoint-125
        _did = absorb_any_sub_phrases
        if _did
          absrb_some_method_name_or_names ; true
        else
          absrb_any_array_as_method_names
        end
      end
      def resolve_some_builder
        if @if_p
          rslv_some_builder_with_if
        else
          rslv_some_builder_without_if
        end
      end
    private
      def rslv_some_builder_with_if
        Headless::Bundles__::Delegating::
          Builder_with_if[ @if_p, rslv_some_builder_without_if ]
      end
      def rslv_some_builder_without_if
        ( @receiver_x_i ? When_Multiple_Delegatees__ : When_One_Delegatee__ ).
          new @name_p, * @receiver_x_i
      end
    private
      def absrb_some_method_name_or_names
        _did = absrb_any_method_name_or_names
        _did or raise ::ArgumentError, say_cant_resolve_method_names ; nil
      end
      def absrb_any_method_name_or_names
        if absrb_any_array_as_method_names
          true
        elsif @x_a.first.respond_to? :id2name
          @method_name_a = [ @x_a.shift ] ; true
        end
      end
      def absrb_any_array_as_method_names
        if ::Array.try_convert @x_a.first
          @method_name_a = @x_a.shift ; true
        end
      end
      def say_cant_resolve_method_names
        "can't resolve delegator method name or names from #{
           Headless::FUN::Inspect[ @x_a.first ] }"
      end
      def if=
        @if_p = @x_a.shift
      end
      def to=
        @receiver_x_i = @x_a.shift
      end
      def to_method=
        @for_single_method = true
        as_i = @x_a.shift
        set_nm_p -> _ { as_i }
      end
      def with_infix=
        prefix_i = @x_a.shift ; suffix_i = @x_a.shift
        set_nm_p -> i { :"#{ prefix_i }#{ i }#{ suffix_i }" }
      end
      def with_suffix=
        suffix_i = @x_a.shift
        set_nm_p -> i { :"#{ i }#{ suffix_i }" }
      end
      def set_nm_p p
        @name_p and raise ::ArgumentError, "definition error: > 1 name proc"
        @name_p = p ; nil
      end
    public
      def resolve_some_method_name_a
        @for_single_method and 1 < @method_name_a.length and
          raise ::ArgumentError, say_single
        @method_name_a
      end
      def say_single
        "'to_method' is for single methods only. cannot delegate these #{
          }to the same method: #{ @method_name_a.map do |i|
            Headless::FUN::Inspect[ i ] end * ', ' }"
      end
    end

    class Builder__
      def initialize nm_p=nil
        @name_p = nm_p || IDENTITY_
      end
    end
    class When_One_Delegatee__ < Builder__
      def build_method i
        up_i = @name_p[ i ]
        -> *a, &p do
          @up_p[].send up_i, * a, & p
        end
      end
      def build_normalized_proc i
        up_i = @name_p[ i ]
        -> a, p do
          @up_p[].send up_i, * a, & p
        end
      end
    end
    WHEN_ONE_DELEGATEE__ = When_One_Delegatee__.new
    class When_Multiple_Delegatees__ < Builder__
      def initialize nm_p, rcvr_x_i
        s = rcvr_x_i.id2name
        if AT__ == s.getbyte( 0 )
          @ivar = rcvr_x_i
          init_for_ivar
        else
          @meth_i = rcvr_x_i
          init_for_method
        end
        super nm_p
      end
    private
      def init_for_ivar
        @i = :ivar ; ivar = @ivar
        @build_method_p = -> i do
          lo_i = @name_p[ i ]
          -> *a, &p do
            instance_variable_get( ivar ).send lo_i, * a, & p
          end
        end ; nil
      end
      def bld_normalized_proc_builder_for_ivar
        ivar = @ivar
        -> i do
          lo_i = @name_p[ i ]
          -> a, p do
            instance_variable_get( ivar ).send lo_i, * a, & p
          end
        end
      end
      def init_for_method
        @i = :meth ; meth_i = @meth_i
        @build_method_p = -> i do
          lo_i = @name_p[ i ]
          -> *a, &p do
            send( meth_i ).send lo_i, * a, & p
          end
        end ; nil
      end
      def bld_normalized_proc_builder_for_meth
        meth_i = @meth_i
        -> i do
          lo_i = @name_p[ i ]
          -> a, p do
            send( meth_i ).send lo_i, * a, & p
          end
        end
      end
    public
      def build_method i
        @build_method_p[ i ]
      end
      def build_normalized_proc i
        ( @build_normalized_proc_p ||= bld_normalized_proc_builder )[ i ]
      end
    private
      def bld_normalized_proc_builder
        send :"bld_normalized_proc_builder_for_#{ @i }"
      end
    end
    AT__ = '@'.getbyte 0

    module IM__

      def _up
        @up_p.call
      end

      def initialize c=nil
        notificate :initialization
        c and @up_p = -> { c }
        super()
      end

      def members
        self.class.members
      end
    end
  end
end
