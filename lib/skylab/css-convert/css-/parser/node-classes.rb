module Skylab::CSS_Convert::CssParsing::CustomTree
  class CustomTree < ::Array
    class << self
      def [] (*a)
        new(a)
      end
    end
    def initialize a
      super(a)
    end
  end
  class Aggregate < CustomTree
    def unparse
      self[1...size].map(&:unparse).join('')
    end
  end
  class Whitesque < CustomTree
    def unparse
      self[1]
    end
  end
end
module Skylab::CSS_Convert::CssParsing::CssFile
  class MyNode < Treetop::Runtime::SyntaxNode; end
  class CssFile < MyNode; end
  class CStyleComment < MyNode; end
  class StyleBlock < MyNode; end
  class Directive__ < MyNode; end
  class Selectors < MyNode; end
  class Selector < MyNode; end
  class ElementSelector < MyNode; end
  class Assignment < MyNode; end
  class AssignmentValue < MyNode; end
  class ElementName < MyNode; end
  class ClassSelector < MyNode; end
  class AssignmentName < MyNode; end
  class CStyleComment < MyNode; end
  class Space < MyNode; end
  class White < MyNode; end
end
