require_relative '..'

require 'skylab/meta-hell/core'

class ::Object  # :2:[#sl-131] - experiment. this is the last extlib.
private
  def notificate i
  end
end

module Skylab::Headless  # ([#013] is reserved for a core node narrative - no storypoints yet)

  module Notificate
    def self.[] mod
      mod.extend MM__ ; mod.send :include, IM__ ; nil
    end
    module MM__
      attr_reader :notificiation_listener_p_a_h
    private
      def add_notification_listener event_i, & subroutine_p
        ( @notificiation_listener_p_a_h ||= { } ).fetch event_i do
          @notificiation_listener_p_a_h[ event_i ] = [ ]
        end.push subroutine_p ; nil
      end
    end
    module IM__
    private
      def notificate i
        h = self.class.notificiation_listener_p_a_h
        if h
          p_a = h[ i ]
          if p_a
            p_a.each do |p|
              instance_exec( & p )
            end
          end
        end
        super
      end
    end
  end

  %i| Autoloader Headless MetaHell |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  module Constants

    MAXLEN = 4096  # (2 ** 12), the number of bytes in about 50 lines
                   # used as a heuristic or sanity in a couple places
  end

  EMPTY_STRING_ = ''.freeze
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

  class Event_  # :[#132] the magical, multipurpose Event base class
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

  class Client_Services  # :#[#067] client services.
    to_proc = -> a do
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
    end ; define_singleton_method :to_proc do to_proc end

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
    end

    # ~ experiment

    def resolve_service i
      if self.class.has_delegated_member? i
        Service_Resolved_As_Bound_Method__.new method i
      else
        @up_p[].resolve_service_notify i
      end
    end
  end

  module Service_Terminal
    to_proc = -> x_a do  # NOT re-entrant
      profile = Profile__.new
      if :intermediate == x_a[ 0 ]
        profile.is_intermediate = true ; x_a.shift
      end
      if :service_module == x_a[ 0 ]
        profile.has_service_module = true ; x_a.shift
        const_set :SVC_MOD_P__, x_a.shift
      end
      profile.freeze
    private
      include Service_Teriminal_IMs__
      define_method :svc_profile do profile end ; private :svc_profile ; nil
    end ; define_singleton_method :to_proc do to_proc end
    Profile__ = ::Struct.new :has_service_module, :is_intermediate
  end
  Service_Resolution__ = ::Struct.new :i, :c_i, :cls
  module Service_Teriminal_IMs__
    def resolve_service_notify i
      if (( svc = any_cached_svc i ))
        svc
      else
        rslv_svc i
      end
    end
  private
    def any_cached_svc i
      (( @svc_h ||= { } )).fetch i do end
    end
    def rslv_svc i
      sr = Service_Resolution__.new i
      @svc_profile ||= svc_profile
      if @svc_profile.has_service_module && (( svc = rslv_svc_via_module sr ))
        svc
      elsif @svc_profile.is_intermediate
        rslv_svc_as_intermediate sr
      else
        rslv_svc_as_terminal sr
      end
    end
    def rslv_svc_via_module sr
      @svc_mod ||= self.class::SVC_MOD_P__.call
      sr.c_i = c_i = sr.i.to_s.gsub( /(?<=^|_)[a-z]/, & :upcase ).intern
      if @svc_mod.const_defined? c_i
        sr.cls = @svc_mod.const_get c_i
        rslv_svc_via_cls sr
      end
    end
    def rslv_svc_via_cls sr
      svc = sr.cls.new client_services ; @svc_h[ sr.i ] = svc ; svc
    end
    def rslv_svc_as_intermediate sr
      cs = client_services
      if cs.class.has_delegated_member? sr.i
        cs.resolve_service sr.i
      else
        @client.resolve_service sr.i
      end
    end
    def rslv_svc_as_terminal sr
      r = rslv_svc_via_method sr.i
      r and @svc_h[ i ] = r ; r
    end
    def rslv_svc_via_method i
      Service_Resolved_As_Bound_Method__.new method i
    end
  end

  class Service_Resolved_As_Bound_Method__
    def initialize bm
      @bound_method = bm
    end
    def invoke a, p
      @bound_method.call( * a, & p )
    end
  end

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
        @name_p = nm_p || MetaHell::IDENTITY_
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
  end  # Delegating

  class Client_Services
    module_exec nil, & Delegating.to_proc
  end

  module Bundles
    Delegating = Delegating
  end
end
module ::Skylab::Headless  # #todo:during-merge
  LINE_SEPARATOR_STRING_ = "\n".freeze
  TERM_SEPARATOR_STRING_ = ' '.freeze
  class Scn_ < ::Proc
    alias_method :gets, :call
  end
end
