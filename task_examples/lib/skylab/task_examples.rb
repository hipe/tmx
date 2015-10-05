require 'skylab/callback'

module Skylab::TaskExamples

  class << self

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ]]

  CLI = nil  # for host
  Home_ = self
  stowaway :Library_, 'lib-'
  NIL_ = nil
  Autoloader_[ TaskTypes = ::Module.new ]
  Textual_Old_Event_ = ::Struct.new :text, :stream_symbol
  UNABLE_ = false
end