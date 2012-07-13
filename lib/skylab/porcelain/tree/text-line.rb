module Skylab::Porcelain
  class Tree::TextLine < Struct.new(:prefix, :node)
    def reset! prefix, node
      self.prefix = prefix
      self.node = node
      self
    end
    def to_s
      "#{prefix}#{node}"
    end
  end
end
