require_relative '..'
require 'skylab/callback/core'

module Skylab::Snag

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  module Core
    Autoloader_[ self ]
  end

  ACHIEVED_= true

  EMPTY_A_ = [].freeze

  EMPTY_S_ = ''.freeze

  Event_ = -> { Snag_::Model_::Event }

  IDENTITY_ = -> x { x }

  stowaway :Lib_, 'library-'

  LINE_SEP_ = "\n".freeze

  NEUTRAL_ = nil

  Snag_ = self

  SPACE_ = ' '.freeze

  UNABLE_ = false

end
