module Skylab::CodeMolester::Config::FileNode
  if false
  class Node < Treetop::Runtime::SyntaxNode
    # jdef eval(env={})
      # :hello
      # tail.elements.inject(head.eval(env)) do |value, element|
      #   element.operator.apply(value, element.operand.eval(env))
      # end
    # end
  end
  class Whitespace < Node
    def content_node?
      false
    end
  end
  end
end

