require_relative '../callback/core'

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

    IN_MOTION_table_actor = -> * x_a do

      _Face = Autoloader_.require_sidesystem :Face
      _Face::CLI::Table.call_via_iambic x_a
    end
  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Autoloader_[ Bundle = ::Module.new ]

  ACHIEVED_ = true
  DASH_ = '-'
  NIL_ = nil
  Plugin_ = self
  SPACE_ = ' '
  UNABLE_ = false
  UNDERSCORE_ = '_'

end
