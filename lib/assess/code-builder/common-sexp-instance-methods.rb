module Hipe
  module Assess
    module CodeBuilder
      #
      # For the specialized sexp classes/modules that either we define or
      # that adapter libraries define
      #
      module CommonSexpInstanceMethods
        extend BracketExtender
        include CommonInstanceMethods
        def to_ruby
          if deep_enhanced?
            other = deep_clone_hack
          else
            other = Marshal.load(Marshal.dump(self))
          end
          ruby = CodeBuilder.ruby2ruby.process other
          ruby
        end



        #
        # get this -- of course we can't serialize our singleton parent
        # accessor methods, nor do we want to serialize that extra
        # parent-related junk
        #
        Wtf = [Symbol, NilClass] # respond_to?(:dup) == true
        def deep_clone_hack
          arr = Array.new(size)
          each_with_index do |mixed,idx|
            child = nil
            if mixed.kind_of?(Sexp)
              if mixed.respond_to?(:deep_clone_hack)
                child = mixed.deep_clone_hack
              else
                child = Marshal.load(Marshal.dump(mixed))
              end
            elsif Wtf.include?(mixed.class)
              child = mixed
            elsif mixed.respond_to?(:dup)
              child = mixed.dup
            else
              fail("huh?: #{mixed}")
            end
            arr[idx] = child
          end
          sexp = Sexp.new(*arr)
          sexp
        end

        # this to us is just a pita we inheirited from Sexp
        def method_missing meth, *args
          raise NoMethodError.new("undefined method `#{meth}' for "<<
            "\"#{self}\":#{self.class}")
        end


        #
        # basic reflection
        #

        def is_module?
          self[0] == :module
        end
        def is_block?
          self[0] == :block
        end

        #
        # end basic reflection
        #



        #
        # iterators and searchers
        #

        def find_all_with_index &block
          founds = []
          each_with_index do |node, idx|
            if block.call(node)
              founds.push [node, idx]
            end
          end
          founds
        end
        def each_node_of_type(type,&block)
          each_with_index do |node, idx|
            if node.kind_of?(Sexp) && node[0]==type
              block.call(node,idx)
            end
          end
        end
        def has_node? sexp
          !! detect { |x| x == sexp }
        end
        def deep_find_first sexp
          deep_enhance! unless deep_enhanced?
          found = nil
          each do |node|
            if node == sexp
              found = node
              break
            else
              if node.kind_of?(Sexp)
                found = node.deep_find_first(sexp)
                break if found
              end
            end
          end
          found
        end

        #
        # barf on node not found. no guarantee that the resulting
        # tree is syntactically correct.
        #
        def replace_node search_mixed, replace_mixed
          search = CodeBuilder.to_sexp(search_mixed)
          replace = CodeBuilder.to_sexp(replace_mixed)
          found = deep_find_first(search)
          if ! found
            fail "couldn't find node: #{search.to_ruby}"
           end
           found.parent.replace_child!(found, replace)
           nil
        end

        #
        # end interators and searchers
        #



        #
        # parent-related methods
        #

        def parent= parent
          fail("sexp node already has parent") if respond_to? :parent
          fail("parent must have node_id") unless parent.respond_to? :node_id
          parent_id = parent.node_id
          def! :parent_id, parent_id
          meta.send(:define_method, :parent){Nodes[parent_id]}
          nil
        end
        def nil_parent!
          fail("Can't nil-out parent when parent does not exist") unless
            has_parent?
          meta.send(:define_method, :parent_id){nil}
          meta.send(:define_method, :parent){nil}
        end
        def has_parent?
          respond_to?(:parent) && parent
        end
        def find_parent(symbol)
          if ! parent
            nil
          elsif parent.first == symbol
            parent
          else
            parent.find_parent(symbol)
          end
        end

        #
        # barf on child not found
        #
        def index_of_child child
          found = nil
          node_id = child.node_id
          each_with_index do |child, idx|
            next unless child.respond_to?(:node_id)
            if child.node_id == node_id
              found = idx
              break
            end
          end
          if ! found
            fail("no child of mine: (##{child.node_id} is not in #{node_id}")
          end
          found
        end

        #
        # if we need to return replaced child we can, but we have to consider
        # if and when to destroy it
        #
        def replace_child! child, nu
          idx = index_of_child child
          self[idx] = nu
          # debugger;  'make sure to_ruby works'
          nil
        end

        #
        # end parent methods
        #
        #


        #
        # enhancements
        #

        def register!
          if respond_to?(:node_id)
            fail("make sure you don't register more than once!")
          end
          node_id = CodeBuilder::Nodes.register(self)
          def! :node_id, node_id
        end

        #
        # @todo this will break on some node types
        #
        def enhance_sexp_node!
          return unless any?
          case self[0]
          when :module; ModuleySexp[self]
          when :scope;  ScopeySexp[self]
          when :block;  BlockeySexp[self]
          when :class;  ClassySexp[self]
          when :call, :arglist, :colon2, :const, :lit, :hash,
               :lasgn, :str, :if, :lvar, :defs, :self, :args, :iter
          else
            puts "\n\n\n#{self[0].inspect}\n\n\n"
            debugger
            fail("implement for #{self[0]}")
          end
        end

        attr_reader :deep_enhanced
        alias_method :deep_enhanced?, :deep_enhanced

        def deep_enhance! parent=nil
          if @deep_enhanced
            fail("check deep_enhanced? if you're not sure. "<<
              "we definately don't want to repeat this.")
          end
          if parent.nil?
            enhance_sexp_node!
          end
          register!
          if parent
            self.parent = parent
          else
            # self.nil_parent! not sure why
          end
          mine = 1
          each do |node|
            next unless node.kind_of?(Sexp)
            CommonSexpInstanceMethods[node]
            node.enhance_sexp_node!
            mine += node.deep_enhance!(self)
          end
          @deep_enhanced = true
          mine
        end

        #
        # end enhancements
        #


      end
    end
  end
end
