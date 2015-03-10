require_relative '..'
require_relative '../brazen/core'

module Skylab::Treemap

  Callback_ = ::Skylab::Callback

  class << self

    define_method :application_kernel_, ( Callback_.memoize do
      Brazen_::Kernel.new Treemap_
    end )
  end  # >>

  Brazen_ = ::Skylab::Brazen
  IDENTITY_ = -> { x }
  Treemap_ = self

  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]
end
