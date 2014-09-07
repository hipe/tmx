
# read [#005]:#this-node-looks-funny-because-it-is-multi-domain

require_relative '../callback/core'

module Skylab::GitViz

  Autoloader_ = ::Skylab::Callback::Autoloader

  Callback_ = ::Skylab::Callback

  Callback_Tree_ = Callback_::Tree

  CONTINUE_ = nil

  EMPTY_A_ = [].freeze

  EMPTY_P_ = -> {}

  GitViz = self

  Name_ = Callback_::Name

  PROCEDE_ = true

  Scn_ = Callback_::Scn

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

end
