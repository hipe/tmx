require_relative '../test-support'

module Skylab::Headless::TestSupport::NLP::EN

  ::Skylab::Headless::TestSupport::NLP[ TS_ = self ]

  include Constants   # so you can say 'TS' (the right one!)

  extend TestSupport_::Quickie

  TestSupport_::Quickie.enable_kernel_describe

  Headless_ = Headless_

  MetaHell_ = Headless_::Library_::MetaHell

  module ModuleMethods

    include MetaHell_::Class::Creator::ModuleMethods

  end

  module InstanceMethods

    let :meta_hell_anchor_module do
      ::Module.new
    end
  end

  Subject_ = -> do
    Headless_::NLP::EN
  end
end
