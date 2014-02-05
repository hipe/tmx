
# read [#005]:#this-node-looks-funny-because-it-is-multi-domain

require_relative '../callback/core'

module Skylab::GitViz

  Autoloader_ = ::Skylab::Callback::Autoloader

  Callback_ = ::Skylab::Callback

  Callback_Tree_ = Callback_::Tree

  Name_ = Callback_::Name

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  GitViz = self

end
