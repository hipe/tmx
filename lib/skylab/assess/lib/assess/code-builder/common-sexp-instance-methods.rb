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

        # small pita inheirited from Sexp
        def method_missing meth, *args
          raise NoMethodError.new("undefined method `#{meth}' for "<<
            "\"#{self}\":#{self.class}")
        end

        def is_module?
          self[0] == :module
        end

        def is_block?
          self[0] == :block
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
        def has_node? sexp
          !! detect { |x| x == sexp }
        end

        # must match sexp exactly
        # @todo refactor this into next
        def deep_find_first sexp=nil, &block
          if sexp.nil?
            return deep_find_first_node(&block)
          end
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

        # see above
        def deep_find_first_node &block
          deep_enhance! unless deep_enhanced?
          found = nil
          if yield self
            found = self
          else
            each do |node|
              next unless node.kind_of?(Array) # catch errors
              if yield node
                found = node
                break
              elsif (found = node.deep_find_first_node(&block))
                break
              end
            end
          end
          found
        end

        def deep_find_all &block
          deep_enhance! unless deep_enhanced?
          founds = []
          founds.push(self) if yield(self)
          each do |node|
            next unless node.kind_of?(Array) # catch errors
            if yield node
              founds.push node
            elsif (childs_found = node.deep_find_all(&block)).any?
              founds.concat childs_found
            end
          end
          founds
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

        CodepathRe = RegexpExtra[
          re = %r{ \A
            ([a-z]+)         # the symbol name
            (?::             # we dont want the colon
              (              # optionally a value like a class name
                (?: [^/\\] | \\/ )+ # the only escape sequence is fwd slash
              )
            )?
            / ?              # eat any trailing separator slash
          }x
        ]

        def codepath path
          orig_path = path.dup
          symbol, value, value_index = codepath_parse path
          if path.empty?
            node = deep_find_first_node do |node|
              node[0] == symbol && (
                value_index.nil? ||
                node[value_index] == value
              )
            end
            return node
          else
            all = codepath_all(orig_path)
            case all.size
            when 0; nil
            when 1: all.first
            else fail("matched too many with #{path} - use codepath_all")
            end
          end
        end

        def codepath_all path
          symbol, value, value_index = codepath_parse path
          founds = deep_find_all do |node|
            node[0] == symbol &&  (
              value_index.nil? ||
              node[value_index] == value
            )
          end
          if path.empty?
            founds
          else
            next_founds = []
            founds.each do |node|
              child_path = path.dup
              next_founds.concat node.codepath_all(child_path)
            end
            next_founds
          end
        end

        def codepath_parse path
          caps = CodepathRe.parse!(path) or
            fail("invalid codepath: #{path.inspect}")
          symbol = caps[0].to_sym
          meta = Symbols[symbol] or
            fail("unrecognized symbol: #{symbol.inspect}")
          value_index = value = nil
          if caps[1]
            if :str == symbol
              value = caps[1].gsub('\\/','/').gsub('\\\\','\\')
              value_index = 1
            else
              true != meta && (value_index = meta[:value_index]) or
                fail("no value_index defined for #{symbol.inspect}")
              value = caps[1].intern
            end
          end
          [symbol, value, value_index]
        end

        def insert_code_at idx, mixed
          sexp = derive_sexp(mixed)
          self.insert(idx, sexp)
          sexp.parent = self
          sexp
        end

          # careful this is a hacky shortcut
        alias_method :insert_node_at, :insert_code_at

        def parent= parent
          fail("sexp node already has parent") if respond_to? :parent
          fail("parent must have node_id") unless parent.respond_to? :node_id
          parent_id = parent.node_id
          def! :parent_id, parent_id
          meta.send(:define_method, :parent){Nodes[parent_id]}
          nil
        end
        def nillify_parent!
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

        # barf on child not found
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

        def add_child child
          deep_enhance! unless deep_enhanced?
          if registered?
            if child.has_parent?
              fail 'do me'  # we need to implement this. easy.
            end
            child.parent = self
          end
          push child
          nil
        end

        #
        # if we need to return replaced child we can, but we have to consider
        # if and when to destroy it
        #
        def replace_child! child, nu
          idx = index_of_child child
          self[idx] = nu
          fail 'do me'  # make sure to_ruby works
          nil
        end

        def destroy!
          remove
          Nodes[node_id] = :removed
        end

        def remove
          fail("can't remove if doesn't have parent") unless has_parent?
          idx = parent.index_of_child(self)
          fail("huh?") unless idx
          parent[idx,1] = nil
          nillify_parent!
          self
        end

        def registered?; instance_variable_defined?('@registered') end

        def register!
          if respond_to?(:node_id)
            fail("make sure you don't register more than once!")
          end
          node_id = CodeBuilder::Nodes.register(self)
          @registered = true
          def! :node_id, node_id
        end

        # @fixme all nodetypes
        def enhance_sexp_node!
          return unless any?
          symbol = self[0]
          meta = Symbols[symbol]
          resp = nil
          if meta
            if meta.kind_of?(Hash) && klass=meta[:module]
              meta[:module].send(:[], self) # enhance self with module
            end
          else
            puts("add thing for #{symbol.inspect} "<< cute_stack(caller[0]) <<
            " but actually at #{File.basename(__FILE__)}:#{__LINE__}")
            exit # don't hate
          end
        end

        attr_reader :deep_enhanced
        alias_method :deep_enhanced?, :deep_enhanced

        def deep_enhance_with_count! parent=nil
          if instance_variable_defined?('@deep_enhanced')
            fail("check deep_enhanced? if you're not sure. "<<
              "we definately don't want to repeat this.")
          end
          if parent.nil?
            enhance_sexp_node!
          end
          register! unless registered?
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
            mine += node.deep_enhance_with_count!(self)
          end
          @deep_enhanced = true
          mine
        end

        def deep_enhance! *a
          deep_enhance_with_count!(*a)
          self
        end

      private
        def derive_sexp mixed
          case mixed
          when Sexp; return mixed
          when String;
            sexp = CodeBuilder.parse(mixed)
            CommonSexpInstanceMethods[sexp]
            sexp.enhance_sexp_node!
            return sexp
          else
            fail("huh?")
          end
        end
      end
    end
  end
end
