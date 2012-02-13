module Skylab::CodeMolester::Config::FileNode
  module ItemBranchy
    def branch?
      true
    end
    def [] name
      o = item_enumerator.detect { |i| name == i.item_name }
      if o.respond_to?(:branch?) and o.branch?
        o
      else
        o.item_value
      end
    end
  end
end

