module Hipe
  module CssConvert
    module Grammar
      class Node < Treetop::Runtime::SyntaxNode
      end
      class ::ApploList < Node
        def tree
          ["foible", "joible"]
        end
      end
    end
  end
end
      