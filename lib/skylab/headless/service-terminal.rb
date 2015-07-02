module Skylab::Headless

  module Service_Terminal

    to_proc = -> x_a do  # NOT #idempotent
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
      include Instance_Methods__
      define_method :svc_profile do profile end ; private :svc_profile ; nil
    end ; define_singleton_method :to_proc do to_proc end

    Profile__ = ::Struct.new :has_service_module, :is_intermediate

    module Instance_Methods__
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
        Home_::Client_Services::Service_Resolved_As_Bound_Method.
          new method i
      end
    end

    Service_Resolution__ = ::Struct.new :i, :c_i, :cls
  end
end
