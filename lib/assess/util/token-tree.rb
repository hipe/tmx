module Hipe
  module Assess
    class TokenTree

      @all = []
      class << self
        attr_reader :all
      end

      module LeafNode
        def has_children?; false end
        attr_reader :token, :token_tree_id
        def init_token_tree tok, parent=nil
          @token_tree_id = self.class.all.length
          self.class.all[@token_tree_id] = self
          @token = tok
          self.parent = parent if parent
          nil
        end
        def destroy!
          if has_parent?
            parent.child_destroy_notify(self)
          end
          destroy_no_notify!
        end
        def destroy_no_notify!
          destroy_self!
        end
        def parent= node
          fail('no') if respond_to?(:parent)
          parent_id = node.token_tree_id
          meta = class << self; self end
          meta.send(:define_method, :parent_id){parent_id}
          meta.send(:define_method, :parent){self.class.all[parent_id]}
          nil
        end
        def has_parent?
          respond_to? :parent
        end
        def token_tree_flatten
          [[token]]
        end
        def token_tree_path
          if has_parent?
            p = parent.token_tree_path
            p.concat token
            p
          else
            [token]
          end
        end
        def leaf?;   true  end
        def branch?; false end
      end

      module BranchNode
        include LeafNode
        attr_reader :children
        def leaf?;    false end
        def branch?;  true end
        def destroy_children!
          if has_children?
            children.each do |child|
              child.destroy_no_notify!
            end
          end
        end
        def destroy_no_notify!
          destroy_children!
          destroy_self!
          nil
        end
        def destroy_self!
          id = token_tree_id
          entry = self.class.all[id]
          if self.object_id != entry.object_id
            fail("uh oh")
          end
          self.class.all[id] = :destroyed
        end
        def add_child node
          @children ||= []
          node.parent = self
          @children.push node
          nil
        end
        def get_child token
          children.detect{|x| x.token == token}
        end
        alias_method :[], :get_child
        def has_child? key
          children.any?{|x| key==x.token}
        end
        def has_children?
          ! @children.nil? && @children.any?
        end
        def at_path path
          if idx = path.index('/')
            mine, rest = %r{\A([^/]*)/(.*)\z}.match(path).captures
            child = get_child(mine)
            child.at_path(rest)
          else
            get_child(path)
          end
        end
        def deep_children
          arr = []
          children.each do |child|
            if child.branch?
              arr.concat child.deep_children
            else
              arr.push child
            end
          end
          arr
        end
        # add self last. depth first for folder removal.
        def deep_branch_children
          if self.branch?
            arr = []
            children.each do |child|
              if child.branch?
                arr.concat child.deep_branch_children
              end
            end
            arr.push self
            arr
          else
            nil # caller shouldn't be asking for branch children anyway
          end
        end
        def token_tree_flatten
          if ! has_children?
            my_matrix = [[token]]
          else
            my_matrix = []
            token = self.token
            children.each do |c|
              child_matrix = c.token_tree_flatten
              child_matrix.each do |row|
                row.unshift(token) if token
                my_matrix.push row
              end
            end
          end
          my_matrix
        end
      end

      include BranchNode

      def initialize tok
        initialize_token_tree tok
      end

    private

      def def!(name, value)
        fail('no') if respond_to?(name)
        meta.send(:define_method, name){value}
      end
      def meta
        class << self; self end
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
    end
  end
end
