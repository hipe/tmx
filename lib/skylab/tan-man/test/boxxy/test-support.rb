# bootstrapping START
#
# TanMan core relies on Boxxy, so we have to sidestep pulling in TanMan during
# boxxy's development. Note we stowaway inside of metahell test support for now,
# which is probably our future home.  This ugliness would subside then.

require_relative '../../../meta-hell/test/test-support'
module Skylab::TanMan
  defined? Inflection or Inflection = ::Skylab::Autoloader::Inflection
  defined? MetaHell or MetaHell = ::Skylab::MetaHell # ick sorry
  defined? TanMan or TanMan = self
end
require_relative '../../boxxy'

# bootstrapping END

require 'skylab/test-support/core'

module Skylab::MetaHell::TestSupport::Boxxy
  ::Skylab::TestSupport::Regret[ self ]

  MetaHell = ::Skylab::MetaHell
  TanMan = ::Skylab::TanMan

  module ModuleMethods
    include MetaHell::Klass::Creator::ModuleMethods

  end


  module InstanceMethods
    extend MetaHell::Let
    include MetaHell::Klass::Creator::InstanceMethods

    let( :meta_hell_anchor_module ) do
      o = ::Module.new
      o.singleton_class.send(:define_method, :to_s) { "Wahoo" }
      o
    end
  end
end
