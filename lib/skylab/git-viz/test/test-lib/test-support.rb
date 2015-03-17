require_relative '../test-support'

module Skylab::GitViz::TestSupport::Test_Lib

  ::Skylab::GitViz::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods

    def new_string_IO_
      Top_TS_.lib_.string_IO.new
    end
  end

  Callback_ = Callback_
  GitViz_ = GitViz_
  Top_TS_ = Top_TS_

end
