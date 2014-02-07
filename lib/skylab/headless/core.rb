require_relative '../callback/core'

class ::Object  # :2:[#sl-131] - experiment. this is the last extlib.
private
  def notificate i
  end
end

module Skylab::Headless  # ([#013] is reserved for a core node narrative - no storypoints yet)

  Autoloader_ = ::Skylab::Callback::Autoloader
  Callback_ = ::Skylab::Callback
  DASH_ = '-'.getbyte 0
  EMPTY_STRING_ = ''.freeze
  EMPTY_A_ = [].freeze
  Headless = self
  IDENTITY_ = -> x { x }
  LINE_SEPARATOR_STRING_ = "\n".freeze
  MONADIC_TRUTH_ = -> _ { true }
  Scn_ = Scn = Callback_::Scn
  TERM_SEPARATOR_STRING_ = ' '.freeze
  WRITEMODE_ = 'w'.freeze

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

end
