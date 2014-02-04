module Skylab::Headless

  class Client_Services  # :[#067] client services.

    Headless::Delegating[ self ]

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
        Service_Resolved_As_Bound_Method.new method i
      else
        @up_p[].resolve_service_notify i
      end
    end

    class Service_Resolved_As_Bound_Method
      def initialize bm
        @bound_method = bm
      end
      def invoke a, p
        @bound_method.call( * a, & p )
      end
    end
  end
end
