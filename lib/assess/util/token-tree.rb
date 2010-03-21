module Hipe
  module Assess
    class TokenTree
      @all = []
      class << self
        attr_reader :all
      end
      attr_reader :token, :children, :token_tree_id
      def initialize tok
        @token_tree_id = self.class.all.length
        self.class.all[@token_tree_id] = self
        @token = tok
      end
      def add_child node
        @children ||= []
        node.parent = self
        @children.push node
        nil
      end
      def parent= node
        fail('no') if respond_to?(:parent)
        parent_id = node.token_tree_id
        meta = class << self; self end
        meta.send(:define_method, :parent_id){parent_id}
        meta.send(:define_method, :parent){self.class.all[parent_id]}
        nil
      end
      def get! token
        if (idx = children.index{|c| c.token == token })
          children[idx]
        else
          new_child = TokenTree.new(token)
          new_child.parent = self
          children.push new_child
          new_child
        end
      end
      def flatten
        if children.nil? || ! children.any?
          my_results = [[token]]
        else
          my_results = []
          children.each do |c|
            if ! token
              my_results.concat c.flatten
            else
              my_results.concat c.flatten.map{|x| x.unshift(token); x}
            end
          end
        end
        my_results
      end
      def def!(name, value)
        fail('no') if respond_to?(name)
        meta.send(:define_method, name){value}
      end
    private
      def meta
        class << self; self end
      end
    end
  end
end
