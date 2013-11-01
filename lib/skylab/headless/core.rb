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
        class << self ; alias_method :orig_new, :new end
        define_singleton_method :new do | * i_a, & p |
          args_notify_p and args_notify_p[ i_a, p ]
          ::Class.new( self ).class_exec do
            class << self ; alias_method :new, :orig_new end
            Members[ self, i_a ]
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

  module Members
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
          _class = if const_defined? const_i
            ::Class.new const_get const_i
          else
            ::Class.new( Client_Services ).class_exec do
              class << self ; alias_method :new, :orig_new end
              self
            end
          end
          r = const_set const_i, _class
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

      alias_method :orig_new, :new

      def new * two_or_more_i_a, & required_defn_p
        1 < two_or_more_i_a.length or raise ::ArgumentError, "calling 'new' #{
          }directly on this class is only for creating compound service clss"
        ::Class.new( self ).class_exec do
          class << self ; alias_method :new, :orig_new end
          const_set :DEEP_STREAM_IVAR_A__, two_or_more_i_a.
            map { |i| :"@#{ i }" }
          const_set :DEEP_STREAM_H__,
            ::Hash[ two_or_more_i_a.map { |i| [ i, :"@#{ i }" ] } ]
          class_exec( & required_defn_p )
          def initialize * deep_a
            ivar_a = self.class::DEEP_STREAM_IVAR_A__
            ( 0 ... [ deep_a.length, ivar_a.length ].max ).each do |d|
              instance_variable_set ivar_a.fetch( d ), deep_a.fetch( d )
            end ; nil
          end
          self
        end
      end

      def inherited otr
        otr.instance_variable_set :@member_i_a__, [ ]
      end

      def delegate * i_a
        dele = build_delegated_method_builder
        i_a.each do |i|
          accept_delegated_method i, dele.build_method( i )
        end
      end
      #
      def delegating * x_a, x  # some iambic is required
        dele = build_delegated_method_builder x_a
        if dele.for_single_method
          accept_delegated_method dele.single_method_name( x ),
            dele.build_single_method
        else
          x.each do |i|
            accept_delegated_method i, dele.build_method( i )
          end
        end
        nil
      end
    private
      def accept_delegated_method i, p
        @member_i_a__ << i
        define_method i, & p
      end
      def build_delegated_method_builder x_a=nil
        Delegating__.new( x_a ).execute
      end
      class Delegating__
        def initialize x_a
          @for_single_method = @name_p = @receiver_i = nil ; @x_a = x_a
          if x_a
            begin
              send :"#{ @x_a.shift }="
            end while x_a.length.nonzero?
          end
        end
      private
        def to=
          @receiver_i = @x_a.shift
        end
        def to_method=
          @for_single_method = true
          as_i = @x_a.shift
          name_p_notify -> _ { as_i }
        end
        def with_infix=
          prefix_i = @x_a.shift ; suffix_i = @x_a.shift
          name_p_notify -> i { :"#{ prefix_i }#{ i }#{ suffix_i }" }
        end
        def with_suffix=
          suffix_i = @x_a.shift
          name_p_notify -> i { :"#{ i }#{ suffix_i }" }
        end
        def name_p_notify p
          @name_p and raise ::ArgumentError, "definition error: > 1 name proc"
          @name_p = p
        end
      public
        def execute
          ( @receiver_i ? Compound : Monadic ).new @for_single_method,
            @name_p, @receiver_i
        end
        class Builder
          def initialize s, n
            @for_single_method = s ; @name_p = n || MetaHell::IDENTITY_
          end
          attr_reader :for_single_method
          def single_method_name x
            x.respond_to?( :id2name ) or raise ::ArgumentError,
             "using 'to_method' is for single methods only. no implicit #{
              }conversion from #{ x.class } to symbol"
            self.do_me  # #todo
          end
        end
        class Monadic < Builder
          def initialize s, n, _
            super s, n
          end
          def build_method i
            up_i = @name_p[ i ]
            -> *a, &p do
              @up_p[].send up_i, *a, &p
            end
          end
        end
        class Compound < Builder
          def initialize s, n, r
            super s, n
            @receiver_ivar = :"@#{ r }"
          end
          def build_method i
            ivar = @receiver_ivar ; up_i = @name_p[ i ]
            -> *a, &p do
              instance_variable_get( ivar ).send up_i, *a, &p
            end
          end
        end
      end
    end

    def initialize c
      @up_p = -> { c }
    end

    def members ; self.class.members end

    def self.members ;  @member_i_a__.dup end

    def _up ; @up_p.call end
  end
end
