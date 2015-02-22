require_relative '..'
require_relative '../brazen/core'

module Skylab::Treemap

  Autoloader_ = ::Skylab::Callback::Autoloader
  Brazen_ = ::Skylab::Brazen
  Callback_ = ::Skylab::Callback

  Kernel_ = ::Class.new Brazen_::Kernel_  # for now

  if false

  def self.lib_
    @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
  end

  module Lib_

    # sidesys = Autoloader_.build_require_sidesystem_proc

  end
  end

  IDENTITY_ = -> { x }
  Treemap_ = self

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]
end
