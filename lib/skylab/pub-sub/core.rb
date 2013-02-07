require_relative '../semantic/core' # etc

module Skylab::PubSub
  extend ::Skylab::Autoloader

  MetaHell = ::Skylab::MetaHell
  Semantic = ::Skylab::Semantic

  self.const_get :Emitter, false
end
