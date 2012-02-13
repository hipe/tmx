module Skylab::CodeMolester::Config::FileNode
  module ItemBranchy
    def branch?
      true
    end
    def [] name
      o = content_item_enumerator.detect { |i| name == i.item_name }
      if o.respond_to?(:branch?) and o.branch?
        o
      elsif o.respond_to?(:item_value)
        o.item_value
      else
        o
      end
    end
  end
end

