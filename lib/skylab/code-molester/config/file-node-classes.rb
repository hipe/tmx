module Skylab::CodeMolester::Config::FileNode
  module ItemBranchy
    def branch?
      true
    end
    def content_items
      content_item_enumerator.map { |i| i }
    end
    def [] name
      e = content_item_enumerator or fail("no enumerator for #{self.class}. invalid?")
      o = e.detect { |i| name == i.item_name }
      if o.respond_to?(:branch?) and o.branch?
        o
      elsif o.respond_to?(:item_value)
        o.item_value
      else
        o
      end
    end
  end
  class Section < ::Treetop::Runtime::SyntaxNode
    include ItemBranchy
  end
end

