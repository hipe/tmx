require 'skylab/callback'

module Skylab::TaskExamples

  class << self

    def lib_
      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end

    def sidesystem_path
      @___ss_path ||= ::File.expand_path( '../../..', Home_.dir_pathname.to_path )
    end
  end  # >>

  Common_task_ = -> do
    Home_.lib_.task
  end

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ]]

  ACHIEVED_ = true
  CLI = nil  # for host
  EMPTY_S_ = ''
  Home_ = self
  Lazy_ = Callback_::Lazy
  stowaway :Library_, 'lib-'
  NEWLINE_ = "\n"
  NIL_ = nil
  SPACE_ = ' '
  Autoloader_[ TaskTypes = ::Module.new ]
  Textual_Old_Event_ = ::Struct.new :text, :stream_symbol
  UNABLE_ = false
  UNRELIABLE_ = :_unreliable_from_te_
end
