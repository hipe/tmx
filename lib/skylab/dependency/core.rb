require_relative '..'
require 'skylab/callback/core'

module Skylab::Dependency

  class << self

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Dep_ = self
  stowaway :Lib_, 'library-'
  Autoloader_[ TaskTypes = ::Module.new ]
  Textual_Old_Event_ = ::Struct.new :text, :stream_symbol
  UNABLE_ = false
end
