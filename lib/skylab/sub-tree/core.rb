require_relative '../callback/core'

module Skylab::SubTree

  class << self

    def lib_
      @lib ||= SubTree_::Lib_::INSTANCE
    end
  end  # >>

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ Models_ = ::Module.new, :boxxy ]

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  ACHIEVED_ = true

  DASH_ = '-'.freeze

  DEFAULT_GLYPHSET_IDENTIFIER_ = :narrow

  EMPTY_A_ = [].freeze

  EMPTY_P_ = -> {}

  EMPTY_S_ = ''.freeze

  KEEP_PARSING_ = true

  IDENTITY_ = -> x { x }

  stowaway :Library_, 'lib-'

  NEWLINE_ = "\n"

  NIL_ = nil

  SEP_ = ::File::SEPARATOR

  SubTree_ = self

  SPACE_ = ' '.freeze

  UNABLE_ = false

  UNDERSCORE_ = '_'.freeze
end
