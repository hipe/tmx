require_relative '../semantic/core' # etc

module Skylab::PubSub

  extend ::Skylab::Autoloader

  MetaHell = ::Skylab::MetaHell
  PubSub   = self
  Semantic = ::Skylab::Semantic

  self.const_get :Emitter, false

  # (note `FUN` is a stowaway module in emitter.rb)

end
