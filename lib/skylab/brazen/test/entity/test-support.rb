require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  Parent_ = ::Skylab::Brazen::TestSupport

  Parent_[ self ]

  include Constants

  extend TestSupport_::Quickie

  Test_Instance_Methods_ = Parent_::Test_Instance_Methods_

  Enhance_for_test_ = Parent_::Enhance_for_test_

  WITH_MODULE_METHOD_ = Parent_::WITH_MODULE_METHOD_

  Subject_ = -> do
    Brazen_::Entity
  end
end
