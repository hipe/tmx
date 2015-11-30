require 'skylab/callback'

module Skylab::Plugin

  class << self

    def lib_
      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys, _stdlib = Autoloader_.at :build_require_sidesystem_proc,
      :build_require_stdlib_proc

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Parse = sidesys[ :Parse ]

    Stdlib_option_parser = -> do
      require 'optparse'
      ::OptionParser
    end
  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ] ]

  Autoloader_[ Bundle = ::Module.new ]

  ACHIEVED_ = true
  CLI = nil  # for host
  DASH_ = '-'
  EMPTY_A_ = [].freeze
  EMPTY_S_ = ''.freeze
  Home_ = self
  KEEP_PARSING_ = true
  NIL_ = nil
  SPACE_ = ' '
  UNABLE_ = false
  UNDERSCORE_ = '_'

end
