require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  ::Skylab::Brazen::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  Enhance_for_test_ = -> mod do
    mod.send :define_singleton_method, :with, WITH_MODULE_METHOD_
    mod.include Test_Instance_Methods_
    nil
  end

  WITH_MODULE_METHOD_ = -> * x_a do
    ok = nil
    x = new do
      ok = process_iambic_stream_fully iambic_stream_via_iambic_array x_a
    end
    ok && x
  end

  module Test_Instance_Methods_
    def process_fully * x_a
      process_iambic_stream_fully iambic_stream_via_iambic_array x_a
    end
  end

  Subject_ = -> do
    Entity_[]
  end
end
