module Skylab::TestSupport::Regret::API

  API = self
  Face = ::Skylab::TestSupport::Services::Face
  Basic = Face::Services::Basic
  Headless = ::Skylab::Headless
  MetaHell = Face::MetaHell
  TestSupport = ::Skylab::TestSupport
  Face::API[ self ]
  EMPTY_A_ = [].freeze

  action_name_white_rx( /[a-z0-9]$/ )

  before_each_execution do Headless::CLI::PathTools.clear end

  class API::Action < Face::API::Action
  private
    def generic_listener
      @generic_listener ||= -> e do
        if @vtuple[ e.volume ]
          @err.puts instance_exec( & e.message_function )
          true
        end
      end
    end
  end
end
