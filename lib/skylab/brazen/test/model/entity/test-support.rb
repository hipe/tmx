require_relative '../../test-support'

module Skylab::Brazen::TestSupport::Model

  Parent_ = ::Skylab::Brazen::TestSupport

  Parent_[ self ]

end

module Skylab::Brazen::TestSupport::Model::Entity

  Parent_ = ::Skylab::Brazen::TestSupport::Model

  Parent_[ TS_ = self ]

  o = Parent_::Parent_

  Enhance_for_test_ = o::Enhance_for_test_

  Test_Instance_Methods_ = o::Test_Instance_Methods_

  WITH_MODULE_METHOD_ = o::WITH_MODULE_METHOD_

  include Constants

  Brazen_ = Brazen_

  extend TestSupport_::Quickie

  module ModuleMethods

    def with_class & p
      contxt = self
      before :all do
        _THE_CLASS_ = nil.instance_exec( & p )
        contxt.send :define_method, :subject_class do
          _THE_CLASS_
        end
      end
    end
  end

  Subject_ = -> * a, & p do

    if a.length.nonzero? || p
      Brazen_::Model.common_entity( * a, & p )
    else
      Brazen_::Model.common_entity_module
    end
  end
end
