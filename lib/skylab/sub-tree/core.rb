require_relative '../callback/core'

module Skylab::SubTree

  class << self

    def lib_
      @lib ||= SubTree_::Lib_::INSTANCE
    end
  end  # >>

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  EMPTY_S_ = ''.freeze

  KEEP_PARSING_ = true

  stowaway :Library_, 'lib-'

  NEWLINE_ = "\n"

  NIL_ = nil

  SEP_ = ::File::SEPARATOR

  SubTree_ = self

  SPACE_ = ' '.freeze

end
