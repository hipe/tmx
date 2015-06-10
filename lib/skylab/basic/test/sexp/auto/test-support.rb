require_relative '../../test-support'

module Skylab::CodeMolester

  const_get( :Config, false ).const_get( :File )  # ick load treetop :(

  module TestNamespace            # we could etc. but we etc.
    include CM_::TestSupport::Constants
  end

  # (the below mess avoids warnings, is probably closer to the "right" way,
  # and give you an idea what kind of things gave rise to
  # the metahell experiments.)

  module TestNamespace::PersonName_01
    class Node < CM_::Library_::Treetop::Runtime::SyntaxNode
      CM_::Sexp::Auto[ self ]
    end
  end

  module TestNamespace::PersonName_02
    class Node < CM_::Library_::Treetop::Runtime::SyntaxNode
      CM_::Sexp::Auto[ self ]
    end
  end

  module TestNamespace::PersonName_03
    class Node < CM_::Library_::Treetop::Runtime::SyntaxNode
      CM_::Sexp::Auto[ self ]
    end
  end
end
