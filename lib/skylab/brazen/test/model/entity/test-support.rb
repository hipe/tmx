require_relative '../../test-support'

module Skylab::Brazen::TestSupport::Model

  ::Skylab::Brazen::TestSupport[ self ]

end

module Skylab::Brazen::TestSupport::Model::Entity

  ::Skylab::Brazen::TestSupport::Model[ TS_ = self ]

  include Constants

  Brazen_ = Brazen_

  extend TestSupport_::Quickie

  Subject_ = -> do
    Brazen_::Model_::Entity
  end

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
end
