require_relative '../test-support'

module Skylab::Headless::TestSupport::NLP::EN

  ::Skylab::Headless::TestSupport::NLP[ EN_TestSupport = self ] #regret, #courtesy

  include ::Skylab::Headless  # so you can say 'NLP'
  include CONSTANTS   # so you can say 'TS' (the right one!)

  extend TestSupport::Quickie

  MetaHell = MetaHell # #annoy

  module ModuleMethods
    include MetaHell::Klass::Creator::ModuleMethods

  end

  module InstanceMethods
    extend MetaHell::Let

    let :meta_hell_anchor_module do
      ::Module.new
    end
  end
end
