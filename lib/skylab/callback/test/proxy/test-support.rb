require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Proxy::Tee
  ::Skylab::MetaHell::TestSupport::Proxy[ Tee_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  _id = 0

  define_singleton_method :const_set_next do |stem, val|
    const_set "#{ stem }#{ _id += 1 }", val
  end

end
