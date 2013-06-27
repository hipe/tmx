module Skylab::Headless

  class Plugin::Host::Metaservices_::Chain_ < Plugin::Host::Metaservices_

    # #experimental core of the whole headless world: this proxy.
    # (and a fully doubly API-private class to boot.)
    # this is the fifth center of the universe. i don't know how we
    # ended up with so many. (there may only be four..)
    #
    # this metaservices chain works a bit like the ancestor chain in ruby,
    # but instead of a chain of modules, it is a chain of clients (actually,
    # their metaservices). in the same manner that a ruby object resolves
    # a message it receives (a "method call") by going up its ancestor chain
    # looking for a module that has the instance method, this proxy goes up
    # the elements of the chain looking for a metaservices that fulfills the
    # service! FSCKING AWESOME
    #
    # usage:
    #
    #     class API_Client
    #       Headless::Plugin::Host.enhance self do
    #         services :show_a_path, :emphasize_text
    #       end
    #     private
    #       def show_a_path x
    #         "(never see full path) #{ x }"
    #       end
    #       def emphasize_text x
    #         x.upcase
    #       end
    #     end
    #
    #     class Modality_Client
    #       Headless::Plugin::Host::Proxy.enhance self do  # proxy, for grease
    #         services :show_a_path, :do_some_mode_thing
    #       end
    #       def _ph ; @plugin_host end
    #     private
    #       def show_a_path x
    #         "(safe path) #{ x.split( '/' ).last }"
    #       end
    #       def do_some_mode_thing
    #         "whatever"
    #       end
    #     end
    #
    #     Chain_ = Headless::Plugin::Host::Metaservices_::Chain_.new [
    #       Modality_Client::Plugin_Host_::Plugin_Host_Metaservices_,
    #       API_Client::Plugin_Host_Metaservices_ ]
    #
    #     api = API_Client.new
    #     web = Modality_Client.new
    #
    #     msvcs = Chain_.new [
    #       web.instance_variable_get(:@plugin_host).plugin_host_metaservices,
    #       api.plugin_host_metaservices
    #     ]
    #
    #     ( !! ( msvcs.moniker =~ /Modality.+API/ ) )  # => true
    #
    #     msvcs.call_service( :do_some_mode_thing )   # => 'whatever'
    #                                                 # first thing in chain
    #
    #     msvcs.call_service( :emphasize_text, 'hi' ) # => 'HI'
    #                                                 # last thing in chain
    #
    #     msvcs.call_service( :show_a_path, '/foo/bar' ) # => '(safe path) bar'
    #                                                 # earliest thing in chain
    #
    #     svcs = msvcs.build_proxy_for Headless::Plugin::Metaservices_::OMNI_
    #
    #     svcs.do_some_mode_thing # => 'whatever'
    #     svcs.emphasize_text( 'hi' ) # => 'HI'
    #     svcs.show_a_path( 'x/y' ) # => '(safe path) y'

    def self.new msvcs_class_a
      new_kls = super()
      new_kls.const_set :MSVCS_CLASS_A_, msvcs_class_a
      new_kls
    end

    def self.services

      # there is some hi-level duplication of logic here with below because:
      # the service proxy class that is made is kept in constant-land instead
      # of instance-land (for good reasons) hence we cannot cross over from
      # instance-land to tell the constant-land what the names of the services
      # are. alternately we could make the entire "services matrix" table here
      # in constant-land instead of instance-land but that limits us to
      # deriving our matrix from the state as-is at delcaration time, not
      # runtime.
      #
      # i.e, resolving the composition of the set of all names of all services
      # is something we should probably do at declaration time (or lazily, but
      # still in constant-land), while resolving the particular fulfillers of
      # those services is something we should probably do at runtime.

      const! :AGGREGATED_SERVICES_ do
        svcs = Plugin::Host::Metaservices_::Services_.new
        a, h = svcs._ivars
        const_get( :MSVCS_CLASS_A_, false ).each do |msvcs|
          msvcs.services._a.each do |i|
            h.fetch i do
              a << i
              h[ i ] = true
            end
          end
        end
        svcs
      end
    end

    def initialize metasvcs_a
      @metasvcs_a = metasvcs_a
      @has_cache_table = false ; @svc_h = { }
      nil
    end

    def moniker
      "(#{ @metasvcs_a.map { |x| x.moniker } * ', ' })"
    end

    def proc_for_has_service
      @_pfhs ||= -> i do
        @has_cache_table or build_cache_table!
        @svc_h.key? i
      end
    end

    def call_service i, a=nil, b=nil  # assumes above passed
      lookup_fulfiller( i ).call_service i, a, b
    end

  private

    def lookup_fulfiller i
      @has_cache_table or build_cache_table!
      @metasvcs_a.fetch @svc_h.fetch( i ).fetch( 0 )
    end

    def build_cache_table!

      # internally we create a "services matrix" that represents each of the
      # services that each of the modality clients (e.g) offers, in order of
      # service and then metaservices (think "client"). at present a service
      # request to this proxy resolves one particular metaservices simply by
      # dispatching the call to the first it finds that fulfills the service

      @has_cache_table = true
      @svc_h.clear
      @metasvcs_a.each_with_index do |msvcs, idx|
        msvcs.services._a.each do |i|
          @svc_h.fetch( i ) do
            @svc_h[ i ] = [ ]
          end << idx
        end
      end
      nil
    end
  end
end
