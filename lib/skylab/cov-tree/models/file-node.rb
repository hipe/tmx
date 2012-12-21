module Skylab::CovTree


  class Models::FileNode < ::Struct.new :isomorphic_slugs, :types, :children
                                                                # (biggest last)
    extend  Porcelain::Tree::Node::ModuleMethods
    include Porcelain::Tree::Node::InstanceMethods

    def children
      super or self.children = Porcelain::Tree::Children.new
    end

    def children_length
      children.length
    end

    def isomorphic_slugs
      super or self.isomorphic_slugs = []
    end

    attr_accessor :slug_dirname

    def type= t
      0 == types.length or fail 'types is clobberproof'
      types[0] = t
      isomorphic_slugs.length > 0 and isomorphs!
      t
    end

    def types
      super or self.types = []
    end


  protected

    test_basename_rx = CovTree::FUN.test_basename_rx

    define_method :isomorphs! do
      if ! children? and 1 == types.length and 1 == isomorphic_slugs.length
        case types.first
        when :test
          md = slug.match test_basename_rx
          if md
            isomorphic_slugs.push "#{ md.captures.detect { |x| x } }.rb"
          end
        when :code
          # going the other direction would be too computationally annoying
        else
          fail 'sanity'
        end
      else
        fail "hory sheet wat to do here?"
      end
    end


    merge_attributes = [:root, :types, :isomorphic_slugs].freeze

    define_method :merge_attributes do
      merge_attributes
    end


    attr_accessor :root
    alias_method :root?, :root


    def slug= s
      super s
      types.length > 0 and isomorphs!
      s
    end
  end
end
