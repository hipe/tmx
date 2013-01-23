require_relative '..'
require 'skylab/pub-sub/core'

module Skylab::Interface

  Autoloader = ::Skylab::Autoloader
  PubSub = ::Skylab::PubSub

  extend Autoloader
end
