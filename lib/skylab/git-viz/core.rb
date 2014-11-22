
# read [#005]:#this-node-looks-funny-because-it-is-multi-domain

require_relative '../callback/core'

module Skylab::GitViz

  class << self
    def _lib
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end

  Autoloader_ = ::Skylab::Callback::Autoloader
    Callback_ = ::Skylab::Callback

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  Callback_Tree_ = Callback_::Tree

  CONTINUE_ = nil

  DASH_ = '-'.freeze

  EMPTY_A_ = [].freeze

  EMPTY_P_ = -> {}

  GitViz_ = self

  Name_ = Callback_::Name

  PROCEDE_ = true

  Scn_ = Callback_::Scn

  SPACE_ = ' '.freeze

  UNABLE_ = false

  UNDERSCORE_ = '_'.freeze

end
