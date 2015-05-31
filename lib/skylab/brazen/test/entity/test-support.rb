require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  Parent_ = ::Skylab::Brazen::TestSupport

  Parent_[ self ]

  include Constants

  extend TestSupport_::Quickie

  Add_common_methods_ = -> mod do

    mod.send :define_method, :initialize do | & edit_p |
      instance_exec( & edit_p )
    end

    mod.send :define_singleton_method, :with, WITH_MODULE_METHOD_

    NIL_
  end

  Subject_ = -> do
    Brazen_::Entity
  end

  Callback_ = Callback_
  Enhance_for_test_ = Parent_::Enhance_for_test_
  KEEP_PARSING_ = true
  NIL_ = nil
  Test_Instance_Methods_ = Parent_::Test_Instance_Methods_
  WITH_MODULE_METHOD_ = Parent_::WITH_MODULE_METHOD_

end
