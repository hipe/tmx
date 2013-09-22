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
    def self.[] client, p
      client.class_exec do
        class << self
          alias_method :orig_new, :new
        end
        define_singleton_method :new do | * i_a, & p_ |
          ::Class.new( self ).class_exec do
            extend MM__ ; include IM__
            class << self ; alias_method :new, :orig_new end
            const_set :MEMBER_I_A__, i_a.freeze
            module_exec( * p_, & p )
            self
          end
        end
      end
      nil
    end
    module MM__
      def members ; self::MEMBER_I_A__ end
    end
    module IM__
      def members ; self.class.members end
      def to_a ; members.map( & method( :send ) ) end
    end
  end

  class Hooks_
    New_method_produces_subclasses_with_members__[ self, -> do
      members.each do |i|
        _p = :"#{ i }_p"
        define_method :"on_#{ i }" do |*a, &p|
          instance_variable_set :"@#{ _p }",
            ( p ? a << p : a ).fetch( a.length - 1 << 2 )
        end
        attr_reader _p
      end
    end ]
  end

  class Event_
    New_method_produces_subclasses_with_members__[ self, -> p=nil do
      const_set :IVAR_A__, members.map { |i| :"@#{ i }" }
      p and const_set( :MESSAGE_P__, p )
      attr_reader( * members )
    end ]
    def self.[] * x_a
      new( * x_a )
    end
    def initialize * x_a
      x_a.length > self.class::IVAR_A__.length and raise ::ArgumentError, "no"
      self.class::IVAR_A__.each_with_index do |ivar, idx|
        instance_variable_set ivar, x_a[ idx ]  # defaults to nil
      end
      nil
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

  module Bundle

    module Multiset
      def self.[] mod
        mod.extend self
      end

      def apply_iambic_to_client x_a, client
        b_h = ( @ibc ||= build_indexed_bundles_callable )
        begin
          client.module_exec x_a, & b_h[ x_a.shift ].to_proc
        end while x_a.length.nonzero?
        nil
      end

    private

      def build_indexed_bundles_callable
        h = ::Hash.new do |_h, k|
          raise ::KeyError, "not found '#{ k }' - did you mean #{ _h.keys * ' or ' }?"   # #todo lev
        end
        constants.each do |const_i|
          x = const_get const_i, false
          k = if x.respond_to? :bundles_key then x.bundles_key
          elsif UCASE_RANGE__.include? const_i.to_s.getbyte( 1 ) then const_i
          else const_i.downcase end
          h[ k ] = x
        end
        h
      end
      #
      UCASE_RANGE__ = 'A'.getbyte( 0 ) .. 'Z'.getbyte( 0 )
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
        if const_defined? name.as_const, false
          const_get name.as_const
        else
          r = const_set name.as_const, ::Class.new( Client_Services )  # no up
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
      def delegating * x_a, i_a
        st = Delegating__.new
        st[ x_a.shift ] = x_a.shift while x_a.length.nonzero?
        w_sfx_i, = st.to_a
        if w_sfx_i
          name_p = -> i { :"#{ i }#{ w_sfx_i }" }
        end
        i_a.each do |i|
          meth_i_delegates_to_up_meth_i i, name_p[ i ]
        end
        nil
      end
      #
      Delegating__ = ::Struct.new :with_suffix
      #
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
