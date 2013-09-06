module Skylab::Test

  module Adapter

    class Collection < ::Module

      def [] dirname_i  # ('name error' behavior undefined for now)
        ( @cache_h ||= { } ).fetch dirname_i do |i|
          before = constants
          require "#{ @dir_pathname }/#{ i }/front"  # or..
          a = constants - before
          if 1 == a.length
            mod = const_get a[ 0 ], false
            init_adapter_module_with_name_i mod, i
            @cache_h[ i ] = mod
          else
            non_mondaic_number_of_consts_added_notify a
          end
        end
      end

    private

      def non_mondaic_number_of_consts_added_notify a
        a.length.zero? and raise "loading \"#{ i }\" added no #{
          }constants to #{ self }"
        raise "loading \"#{ i }\" must add exactly one constant #{
          }to #{ self } - added: (#{ a * ', ' })"
      end

      def init_adapter_module_with_name_i mod, i
        me = self
        mod.module_exec do
          adapter_moniker_notify i
          @dir_pathname ||= me.dir_pathname.join( i )
          MetaHell::MAARS[ self, false ]
        end
        nil
      end
    end

    module Anchor_Module

      def self.[] mod
        mod.extend Methods_
        nil
      end

      module Methods_

        attr_reader :moniker

      private

        def adapter_moniker_notify i
          @moniker = i
        end
      end
    end

    class Services_

      def initialize adapter_mod, project_services
        @adapter_mod = adapter_mod ; @project_services = project_services
      end

      def new_test_run
        @adapter_mod.const_get( :Test_Run_, false ).new.with(
          :moniker, moniker, :adapter_services, self )
      end

    private

      def moniker
        @adapter_mod.moniker
      end
    end
  end
end
