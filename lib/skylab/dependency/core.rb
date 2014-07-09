require_relative '..'
require 'skylab/callback/core'

module Skylab::Dependency

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  Dep_ = self

  stowaway :Lib_, 'library-'

  module TaskTypes
    Autoloader_[ self ]
  end
end
