require_relative '../test-support'

module Skylab::TanMan::TestSupport::API

  ::Skylab::TanMan::TestSupport[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  module InstanceMethods

    def app_name
      APP_NAME__
    end
    APP_NAME__ = '(tm)'.freeze

  end
end
