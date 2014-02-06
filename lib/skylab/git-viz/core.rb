
# read [#005]:#this-node-looks-funny-because-it-is-multi-domain

require_relative '../callback/core'

module Skylab::GitViz

  Autoloader_ = ::Skylab::Callback::Autoloader

  Callback_ = ::Skylab::Callback

  Callback_Tree_ = Callback_::Tree

  EMPTY_SCN_ = (( Headless_ = Autoloader_.require_sidesystem :Headless ))::
    Scn.new do end

  GitViz = self

  Name_ = Callback_::Name

  Scn_ = Headless_::Scn

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

end
