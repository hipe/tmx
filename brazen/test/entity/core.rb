module Skylab::Brazen::TestSupport

  module Entity

    class << self
      def require_common_sandbox
        # (currently it is defined by having loaded this support file)
        NIL_
      end
    end  # >>
  end

  module Entity_Sandbox

    extend TestSupport_::Quickie

    # -- Functions

    # <-
  Add_common_methods_ = -> mod do

    mod.send :define_method, :initialize do | & edit_p |
      instance_exec( & edit_p )
    end

    mod.send :define_singleton_method, :with, WITH_MODULE_METHOD_

    NIL_
  end
  # ->

    Subject_ = -> do
      Home_::Entity
    end

    # -- Constants (we do X=X because [#ts-044])

    Common_ = Common_
    Enhance_for_test_ = Enhance_for_test_
    Home_ = Home_
    KEEP_PARSING_ = Home_::KEEP_PARSING_
    Test_Instance_Methods_ = Test_Instance_Methods_
    TS_ = self
    WITH_MODULE_METHOD_ = WITH_MODULE_METHOD_
  end
end
