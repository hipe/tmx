require_relative '../../test-support'

module Skylab::System::TestSupport::Doubles_Stubbed_System

  parent = ::Skylab::System::TestSupport
  parent[ TS_ = self ]
  TestSupport_ = parent::TestSupport_

  extend TestSupport_::Quickie

  module InstanceMethods

    def new_string_IO_
      Home_.lib_.string_IO.new
    end
  end

  s = nil
  Path_for_ = -> tail_s do

    s ||= parent.dir_pathname.join( 'doubles/stubbed-system' ).to_path

    File.join s, tail_s
  end

  Subject_ = -> do
    Home_::Doubles::Stubbed_System
  end

  Callback_ = parent::Callback_
  Home_ = parent::Home_
  NIL_ = nil
end
