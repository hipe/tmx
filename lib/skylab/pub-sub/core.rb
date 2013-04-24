require_relative '../semantic/core' # etc
require 'skylab/basic/core'

module Skylab::PubSub

  %i[ Autoloader Basic MetaHell PubSub Semantic ].each do |i|
    const_set i, ::Skylab.const_get( i )
  end

  extend MetaHell::Autoloader::Autovivifying::Recursive

  self.const_get :Emitter, false

  # (note `FUN` is a stowaway module in emitter.rb)

  MAARS = MetaHell::Autoloader::Autovivifying::Recursive
end
