module Skylab::Headless

  class Event  # :[#132] the magical, multipurpose Event base class

    module New_method_produces_subclasses_with_members__
      def self.[] client, * x_a
        st = Params__.new ; st[ x_a.shift ] = x_a.shift while x_a.length.nonzero?
        new_class_notify_p, args_notify_p = st.to_a
        client.class_exec do
          class << self ; alias_method :orig_new, :new end
          define_singleton_method :new do | * i_a, & p |
            args_notify_p and args_notify_p[ i_a, p ]
            ::Class.new( self ).class_exec do
              class << self ; alias_method :new, :orig_new end
              Members__[ self, i_a ]
              module_exec( * p, & new_class_notify_p )
              self
            end
          end
        end
        nil
      end
      #
      Params__ = ::Struct.new :with_new_class, :with_args
    end

    module Members__
      def self.[] mod, i_a=nil
        mod.module_exec do
          extend MM__ ; include IM__
          i_a and const_set :MEMBER_I_A__, i_a.freeze
        end ; nil
      end
      module MM__
        def members ; self::MEMBER_I_A__ end
      end
      module IM__
        def members ; self.class.members end
        def to_a ; members.map( & method( :send ) ) end
      end
    end

    New_method_produces_subclasses_with_members__[ self,
      :with_args, -> x_a, p do
        x_a.length.zero? && p &&
          (( i_a = p.parameters.map( & :last ) )).length.nonzero? and
            x_a.concat i_a
        nil
      end,
      :with_new_class, -> p=nil do
        const_set :IVAR_A__, members.map { |i| :"@#{ i }" }
        attr_reader( * members )
        if p
          if p.arity.zero?
            class_exec( & p )
          else
            const_set :MESSAGE_P__, p
          end
        end
        nil
      end ]

    def self.[] * x_a
      new( * x_a )
    end
    def initialize * x_a
      x_a.length > self.class::IVAR_A__.length and raise ::ArgumentError, "no"
      self.class::IVAR_A__.each_with_index do |ivar, idx|
        instance_variable_set ivar, x_a[ idx ]  # defaults to nil
      end ; nil
    end
    def any_message_proc
      self.class.const_defined?( :MESSAGE_P__ ) and self.class::MESSAGE_P__
    end
    def message_proc
      self.class::MESSAGE_P__
    end
    def some_message_proc
      any_message_proc or fail "no message proc defined for #{ self.class }"
    end

    class Hooks  # not related to events except w/ this shared implementation
      New_method_produces_subclasses_with_members__[ self,
        :with_new_class, -> cls_p=nil do
          members.each do |i|
            _p = :"#{ i }_p"
            define_method(( m = :"on_#{ i }")) do |*a, &p|
              instance_variable_set :"@#{ _p }",
                ( p ? a << p : a ).fetch( a.length - 1 << 2 )
            end
            alias_method i, m
            attr_reader _p
          end
          cls_p and class_exec( & cls_p )
      end ]
    end
  end
end
