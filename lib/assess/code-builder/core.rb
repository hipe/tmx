module Hipe
  module Assess
    module CodeBuilder

      #
      # any nodes that want to can register themselves with this
      # (typically in the constructor) so that other nodes can refer to them
      # by id.  (note that garbage collection will not reclaim these nodes
      # unless they assume responsibility for nilling this out somehow)
      #
      Nodes = Array.new
      class << Nodes
        def register obj
          id = length
          self[id] = obj
          id
        end
      end

      def module_name_sexp str
        str = str.to_s
        if str.nil?
          nil
        elsif str.include?(':')
          parser.process str
        else
          sym = str.to_sym
          s(:const, sym)
        end
      end

      def const_get_deep name
        name.split(/::/).inject(Object) { |k, n| k.const_get n }
      end

      module BracketExtender
        def [] item
          unless item.kind_of?(Sexp)
            msg = "Can't turn #{item}:#{item.class} into a #{self}"
            fail(msg)
          end
          item.extend self unless item.kind_of? self
          item
        end
      end

      #
      # For the specialized sexp classes/modules that either we define or
      # that adapter libraries define
      #
      module CommonSexpInstanceMethods
        extend BracketExtender
        include CommonInstanceMethods
        def to_ruby
          other = Marshal.load(Marshal.dump(self))
          ruby = CodeBuilder.ruby2ruby.process other
          ruby
        end
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
        def meta
          class << self; self end
        end
        # this seems to be just a pita, that we inheirit from Sexp
        def method_missing meth, *args
          raise NoMethodError.new("undefined method `#{meth}' for "<<
            "\"#{self}\":#{self.class}")
        end
        def has_node? sexp
          !! detect { |x| x == sexp }
        end
        def register!
          if respond_to?(:node_id)
            fail("make sure you don't register more than once!")
          end
          node_id = CodeBuilder::Nodes.register(self)
          self.meta.send(:define_method, :node_id){node_id}
        end
        def is_module?
          self[0] == :module
        end
        def is_block?
          self[0] == :block
        end
        # deep_enhance! first (and only once)
        def deep_find_first sexp
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
        # @todo this is skipping a lot of stuff
        #
        def enhance!
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
        def parent= parent
          fail("no") if respond_to? :parent
          fail("no") unless parent.respond_to? :node_id
          parent_id = parent.node_id
          meta.send(:define_method, :parent_id){parent_id}
          meta.send(:define_method, :parent){Nodes[parent_id]}
          nil
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
        def nil_parent!
          fail("no") if respond_to? :parent
          meta.send(:define_method, :parent){nil}
        end
        def deep_enhance! parent=nil
          if parent.nil?
            enhance!
          end
          register!
          if parent
            self.parent = parent
          else
            self.nil_parent!
          end
          mine = 1
          each do |node|
            next unless node.kind_of?(Sexp)
            CommonSexpInstanceMethods[node]
            node.enhance!
            mine += node.deep_enhance!(self)
          end
          mine
        end
      end
    end
  end
end
