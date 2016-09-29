require_relative 'test-support'

module Skylab::Basic::TestSupport

  # below we violate some norms

  module PersonName_01

    class Node < Home_.lib_.treetop::Runtime::SyntaxNode

      Home_::Sexp::Auto[ self ]
    end
  end

  module PersonName_02

    class Node < Home_.lib_.treetop::Runtime::SyntaxNode

      Home_::Sexp::Auto[ self ]
    end
  end

  module PersonName_03

    class Node < Home_.lib_.treetop::Runtime::SyntaxNode

      Home_::Sexp::Auto[ self ]
    end
  end
end
