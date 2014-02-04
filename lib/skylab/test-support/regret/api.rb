module Skylab::TestSupport

  module Regret

    module API
      API = self
      Regret = Regret
      TestSupport = TestSupport_

      %i| Basic Face Headless MetaHell |.each do |i|
        const_set i, TestSupport::Library_.const_get( i, false )
      end

      WRITEMODE_ = Headless::WRITEMODE_

      DEFAULT_CORE_BASENAME_ = "core#{ ::Skylab::Autoloader::EXTNAME }"

    end

    TestSupport_::Library_::Face::API[ self ]

    action_name_white_rx( /[a-z0-9]$/ )

    before_each_execution do
      Headless::CLI::PathTools.clear
    end

    module API

      def self.debug!
        ( @system_api_client ||= Client.new ).do_debug = true
      end

      class Client

        Headless::Plugin::Host.enhance self do
          services :pth, :invitation
        end

        attr_accessor :do_debug

        def pth
          @pth ||= -> p { p }
        end

        def invitation
          # we don't have output resources on hand, so we cannot.
          nil
        end

        def service_provider_for ex  # for raw API calls, development hack -
          # if API.do_debug is on **at the time of the puts operation**
          # write the message to the system's stderr, else disregard the
          # message.
          @system_service_provider ||= begin
            @do_debug ||= nil
            stderr = TestSupport::Stderr_[]
            System_Services_.new( Dynamic_Puts_Proxy_.new do |s|
              @do_debug and stderr.puts s
            end )
          end
        end

      private

        def raw_request_param_a_notify y
          super
          y << :expression_agent_p << method( :get_expression_agent )
        end

        def get_expression_agent _bound
          Expression_agent_class__[].new
        end
      end

      class System_Services_ < Basic::Struct[ :err ]
        Headless::Plugin::Host.enhance self do
          services :err, :ivar
        end
      end

      class Dynamic_Puts_Proxy_ < ::Proc
        alias_method :puts, :call
      end

      class Action < Face::API::Action

        def set_vtuple x
          did = false
          @vtuple ||= begin ; did = true ; x end
          did or raise "sanity - vtuple already set"
        end

      private

        def snitch
          @sn ||= bld_snitch
        end

        def bld_snitch
          _vtu = @vtuple or raise say_no_vtuple
          _vtu.make_snitch @err, some_expression_agent
        end

        def say_no_vtuple
          "sanity -  no vtuple for this instance of #{ self.class }"
        end

        def generic_listener
          @generic_listener ||= bld_generic_listener_p
        end

        def bld_generic_listener_p
          -> e do
            if @vtuple[ e.volume ]
              @err.puts instance_exec( & e.message_proc )
              true
            end
          end
        end
      end

      module Lib_
        memo = -> p do
          p_ = -> { x = p.call ; p_ = -> { x } ; x }
          -> { p_.call }
        end
        subsys = -> i do
          memo[ -> do
            _slug = i.to_s.gsub( %r((?<=[a-z])(?=[A-Z])), '-' ).downcase
            require "skylab/#{ _slug }/core"
            ::Skylab.const_get i, false
          end ]
        end
        Basic = subsys[ :Basic ]
        Face = subsys[ :Face ]
        Headless = subsys[ :Headless ]
        Callback = subsys[ :Callback ]
        StringScanner = memo[ -> { require 'strscan' ; ::StringScanner } ]
        SubTree = subsys[ :SubTree ]
      end

      Expression_agent_class__ = -> do
        Lib_::Face[]::API::Normalizer_::Expression_agent_class[]
      end
    end
  end
end
