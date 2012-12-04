require_relative '../test-support'


module ::Skylab::CodeMolester

  self::Config::File || nil # ick load treetop :(

  module TestNamespace            # we could etc. but we etc.
    include ::Skylab::CodeMolester::TestSupport::CONSTANTS
  end

  module TestNamespace::PersonName
    class Node < ::Treetop::Runtime::SyntaxNode
      extend CodeMolester::AutoSexp
    end
  end
end
