require_relative '../test-support'


module ::Skylab::CodeMolester

  self::Config::File || nil # ick load treetop :(

  module TestNamespace            # we could etc. but we etc.
    include ::Skylab::CodeMolester::TestSupport::CONSTANTS
  end

  # (the below mess avoids warnings, is probably closer to the "right" way,
  # and give you an idea what kind of things gave rise to
  # the metahell experiments.)

  module TestNamespace::PersonName_01
    class Node < CodeMolester::Services::Treetop::Runtime::SyntaxNode
      extend CodeMolester::AutoSexp
    end
  end

  module TestNamespace::PersonName_02
    class Node < CodeMolester::Services::Treetop::Runtime::SyntaxNode
      extend CodeMolester::AutoSexp
    end
  end

  module TestNamespace::PersonName_03
    class Node < CodeMolester::Services::Treetop::Runtime::SyntaxNode
      extend CodeMolester::AutoSexp
    end
  end
end
