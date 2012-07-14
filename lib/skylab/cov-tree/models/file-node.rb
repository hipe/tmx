require 'skylab/porcelain/tree'

module Skylab::CovTree
  class Models::FileNode < ::Struct.new(:isomorphic_slugs, :types, :children) # big last
    extend  ::Skylab::Porcelain::Tree::Node::ModuleMethods
    include ::Skylab::Porcelain::Tree::Node::InstanceMethods
    alias_method :_children, :children # eew sorry
    def children
      super or self.children = ::Skylab::Porcelain::Tree::Children.new
    end
    def children_length
      _children ? _children.length : 0
    end
    def isomorphs!
      if ! children? and 1 == types.length and 1 == isomorphic_slugs.length
        case types.first
        when :test
          if md = slug.match(TEST_BASENAME_RE)
            isomorphic_slugs.push "#{md.captures.detect { |x| x }}.rb"
          end
        when :code # going the other direction would be too computationally annoying
        else ; fail("huh?")
        end
      else
        fail("hory sheet what to do here?")
      end
    end
    def isomorphic_slugs
      super or self.isomorphic_slugs = []
    end
    MERGE_ATTRIBUTES = [:root, :types, :isomorphic_slugs]
    def merge_attributes ; MERGE_ATTRIBUTES.dup end
    attr_accessor :root
    attr_accessor :slug_dirname
    def slug= s
      super(s)
      types.length > 0 and isomorphs!
      s
    end
    def type= t
      0 == types.length or fail('types is clobberproof')
      types[0] = t
      isomorphic_slugs.length > 0 and isomorphs!
      t
    end
    def types
      super or self.types = []
    end
  end
end
