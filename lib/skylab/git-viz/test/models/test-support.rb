require_relative '../test-support'

module Skylab::GitViz::TestSupport::Models

  ::Skylab::GitViz::TestSupport[ TS_ = self ]

  include Constants

  GitViz_ = GitViz_

  extend TestSupport_::Quickie

  module InstanceMethods

    def subject_API  # #hook-out for "expect event"
      GitViz_::API
    end
  end
end
