module Skylab::TestSupport

  module Regret

    module API
      API = self

      TestSupport = TestSupport_

      %i| Basic Face Headless MetaHell |.each do |i|
        const_set i, TestSupport::Services.const_get( i, false )
      end

      EMPTY_A_ = [].freeze
    end

    TestSupport_::Services::Face::API[ self ]

    action_name_white_rx( /[a-z0-9]$/ )

    before_each_execution do Headless::CLI::PathTools.clear end

    module API
      class Client
        Headless::Plugin::Host.enhance self do
          services :pth, :invitation
        end

        def pth
          @pth ||= -> p { p }
        end

        def invitation
          # we don't have output resources on hand, so we cannot.
          nil
        end
      end

      class Action < Face::API::Action
      private
        def generic_listener
          @generic_listener ||= -> e do
            if @vtuple[ e.volume ]
              @err.puts instance_exec( & e.message_proc )
              true
            end
          end
        end
      end
    end
  end
end
