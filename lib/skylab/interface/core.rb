require_relative '..'
require 'skylab/pub-sub/core'

module Skylab::Interface

  Autoloader = ::Skylab::Autoloader
  Interface = self # #hiccup
  PubSub = ::Skylab::PubSub

  extend Autoloader
end
