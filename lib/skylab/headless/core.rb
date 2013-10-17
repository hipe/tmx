require_relative '..'

require 'skylab/meta-hell/core'

module Skylab::Headless

  %i| Autoloader Headless MetaHell |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  module CONSTANTS

    MAXLEN = 4096  # (2 ** 12), the number of bytes in about 50 lines
                   # used as a heuristic or sanity in a couple places
  end

  EMPTY_S_ = ''.freeze
  EMPTY_A_ = [ ].freeze
  IDENTITY_ = -> x { x }
  WRITEMODE_ = 'w'.freeze

  Private_attr_reader_ = MetaHell::FUN.private_attr_reader

  ::Skylab::Subsystem[ self ]

  MetaHell::MAARS[ self ]

  module New_method_produces_subclasses_with_members__
    def self.[] client, * x_a
      st = Params__.new ; st[ x_a.shift ] = x_a.shift while x_a.length.nonzero?
      new_class_notify_p, args_notify_p = st.to_a
      client.class_exec do
        class << self
          alias_method :orig_new, :new
        end
        define_singleton_method :new do | * i_a, & p |
          args_notify_p and args_notify_p[ i_a, p ]
          ::Class.new( self ).class_exec do
            extend MM__ ; include IM__
            class << self ; alias_method :new, :orig_new end
            const_set :MEMBER_I_A__, i_a.freeze
            module_exec( * p, & new_class_notify_p )
            self
          end
        end
      end
      nil
    end
    #
    Params__ = ::Struct.new :with_new_class, :with_args
    module MM__
      def members ; self::MEMBER_I_A__ end
    end
    module IM__
      def members ; self.class.members end
      def to_a ; members.map( & method( :send ) ) end
    end
  end

  def self.Hooks_ * i_a, &p
    Hooks_.new( * i_a, &p )
  end

  class Hooks_
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

  class Event_
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
  end

  class Client_Services

    def self.to_proc
      BUNDLE__
    end

    BUNDLE__ = -> a do
      extend MM__ ; include IM__
      did = nil ; p = -> i do
        name = Name__.new i
        define_method i do
          client_services_notify name
        end ; private i
        define_singleton_method name.as_client_services_class_method_name do
          client_services_class_notify name
        end
      end
      while :named == a[ 0 ]
        did ||= true ; a.shift ; p[ a.shift ]
      end
      did or p[ :client_services ]
      nil
    end

    class Name__
      def initialize i ; @i = i end
      def as_ivar ; :"@#{ @i }" end
      def as_proc_const ; @pc_i ||= :"#{ as_const }_Proc" end
      def as_const ; @c_i ||= @i.to_s.gsub( RX__, & :upcase ).intern end
      RX__ = /(?<=\A|_)[a-z]/

      def as_client_services_class_method_name
        @cscmn_i ||= :"#{ @i }_class"
      end
    end

    module MM__
      def client_services_class_notify name
        const_i = name.as_const
        if const_defined? const_i, false
          const_get const_i
        else
          _base_class = if const_defined? const_i
            const_get const_i
          else
            Client_Services
          end
          r = const_set const_i, ::Class.new( _base_class )
          if const_defined? name.as_proc_const, false
            r.class_exec( & const_get( name.as_proc_const ) )
          end
          r
        end
      end
    end

    module IM__
    private

      def client_services_notify name
        if instance_variable_defined?(( ivar = name.as_ivar ))
          instance_variable_get ivar
        else
          instance_variable_set ivar, build_client_services_notify( name )
        end
      end

      def build_client_services_notify name  # might expand
        ( self.class.send name.as_client_services_class_method_name ).new self
      end
    end

    class << self

      def inherited otr
        otr.instance_variable_set :@member_i_a__, [ ]
      end

      def delegate * i_a
        i_a.each { |i| meth_i_delegates_to_up_meth_i i, i  }
      end
      #
      def delegating * x_a, i_a  # must use options
        opt_st = Delegating_Opt_St__.new
        opt_st[ :name_p ] = []
        begin
          OPT_PROTO_H__.fetch( x_a.shift )[ opt_st, x_a ]
        end while x_a.length.nonzero?
        name_p_a, is_single = opt_st.to_a
        1 == name_p_a.length or fail "syntax error - non-one name_p"
        name_p = name_p_a[ 0 ]
        if is_single
          i_a.respond_to?( :id2name ) or fail "syntax - expected single"
          meth_i_delegates_to_up_meth_i i_a, name_p[ i_a ]
        else
          i_a.each do |i|
            meth_i_delegates_to_up_meth_i i, name_p[ i ]
          end
        end
        nil
      end
      #
      Delegating_Opt_St__ = ::Struct.new :name_p, :is_single
      #
      OPT_PROTO_H__ = {
        to: -> st, a do
          st[ :is_single ] = true
          as_i = a.shift
          st[ :name_p ] << -> _ { as_i }
        end,
        with_suffix: -> st, a do
          suffix_i = a.shift
          st[ :name_p ] << -> i { :"#{ i }#{ suffix_i }" }
        end,
        with_infix: -> st, a do
          prefix_i = a.shift ; suffix_i = a.shift
          st[ :name_p ] << -> i { :"#{ prefix_i }#{ i }#{ suffix_i }" }
        end
      }.freeze

      def meth_i_delegates_to_up_meth_i i, up_meth_i
        @member_i_a__ << i
        define_method i do | *a, &p |
          @up_p[].send up_meth_i, *a, &p
        end
      end ; private :meth_i_delegates_to_up_meth_i
    end

    def initialize c
      @up_p = -> { c }
    end

    def members ; self.class.members end

    def self.members ;  @member_i_a__.dup end

    def _up ; @up_p.call end
  end
end
