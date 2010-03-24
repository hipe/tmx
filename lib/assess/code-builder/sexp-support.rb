module Hipe
  module Assess
    module CodeBuilder

      #
      # this puppy defines an experimental collection of modules
      # based around scopes, modules, classes, blocks, etc that
      # is supposed to make it easier and more readable to alter
      # dynamically a parse tree
      #

      module ScopeHavingSexp
        include CommonSexpInstanceMethods
        def self.has_scope_at_index(mod, idx)
          if mod.instance_methods.include? "scope_index"
            fail("uh-oh")
          end
          mod.send(:define_method, :scope_index){idx}
          mod.send(:include, self)
        end

        def scope
          if scope_index >= length
            fail("classes and modules should always have "<<
              "an item at #{scope_index}")
          else
            it = self[scope_index]
            unless it.kind_of?(Sexp) && :scope == it.first
              fail("expecting scope")
            end
            ScopeySexp[it] unless it.kind_of?(ScopeySexp)
            it
          end
        end
      end

      module BlockAutovivifyingSexp
        #
        # don't include this module, call the below
        #
        def self.has_block_at_index(mod, idx)
          if mod.instance_methods.include? "block_index"
            fail("uh-oh")
          end
          mod.send(:define_method, :block_index){idx}
          mod.send(:include, self)
        end

        def block!
          if :self == block_index
            if :block == first
              block = self
            else
              if has_parent? # @todo this is a common pattern. unprune
                debugger; "your so clevr"
              elsif 0 == size
                push(:block) # kind of crazy
                block = self
              else
                debugger; 'you can do it'
              end
            end
          elsif block_index >= length
            block = s(:block)
            self[block_index] = block # careful!
            block
          else
            block = self[block_index]
            unless block.kind_of?(Sexp) && :block == block.first
              block = s(:block, block)
              self[block_index] = block
            end
          end
          BlockeySexp[block] unless block.kind_of? BlockeySexp
          block
        end
      end

      module ModuleAutovivifyingSexp
        #
        # This thing will add new module sexps to itself, so typicially
        # it should only be in a block.  (A scope can also have modules
        # under it but as soon as you want more than one you need a block.)
        #
        include CommonSexpInstanceMethods

        def module! name_sym
          them = find_all_with_index do |node|
            node.kind_of?(Sexp) && node[0]==:module && node[1]==name_sym
          end
          case them.size
          when 0;
            result = CodeBuilder.build_module(name_sym)
            push result
          when 1;
            result, _ = them.first
            ModuleySexp[result] unless result.kind_of?(ModuleySexp)
          else fail("Although this is certainly legit we don't want it here.")
          end
          return result
        end

      end

      module ClassAutovivifyingSexp
        include CommonSexpInstanceMethods

        def class! name_sym, parent_str
          parent_str = parent_str.to_s
          scope = self.scope
          block = scope.block!
          them = block.find_all_with_index do |node|
            node.kind_of?(Sexp)  &&
            node.first == :class &&
            node[1]    ==  name_sym
          end
          case them.size
          when 0
            result = CodeBuilder.build_class(name_sym, parent_str)
            block.push result # really?
          when 1
            result, _ = them.first
            ClassySexp[result] unless result.kind_of?(ClassySexp)
            foo = result.parent_class_string
            if foo != parent_str
              fail("parent class mismatch: had #{foo.inspect}, "<<
              "you gave #{parent_str.inspect}")
            end
          else
            fail("don't want to deal with re-opened classes in a file")
          end
          result
        end
      end

      #
      # For sexps that represent modules
      #
      module ModuleySexp
        extend BracketExtender
        include CommonSexpInstanceMethods
        include ClassAutovivifyingSexp
        ScopeHavingSexp.has_scope_at_index(self, 2)
        def module_name_symbol; self[1] end

        class << self

          These2 = [:class, :module]
          def module_tree_for_module_node(sexp)
            thing = TokenTree.new(sexp[1])
            thing.def! :sexp, sexp
            sexp.scope.block!.each do |node|
              if node.kind_of?(Sexp) && These2.include?(node.first)
                child = module_tree_for_module_node node
                thing.add_child(child)
              end
            end
            thing
          end

          #
          # precondition: deep_enhance!d
          # make a token tree with a nil token
          # that has children that are token trees for
          # each child (at this level) that is a class or module.
          # (unless sexp is itself already a module then just
          # call the instance method)
          #
          These3 = [:class, :module, :block]
          def module_tree(sexp)
            require 'assess/util/token-tree'
            if sexp.first == :module
              module_tree_for_module_node(sexp)
            else
              res = TokenTree.new(nil)
              sexp.each_with_index do |node, idx|
                if node.kind_of?(Sexp) && These3.include?(node.first)
                  if node.first == :module
                    res.add_child module_tree_for_module_node(node)
                  else
                    res.add_child module_tree(node)
                  end
                end
              end
              res
            end
          end
        end

        def module_tree
          ModuleySexp.module_tree_for_module_node(self)
        end

      end

      #
      # For sexps that represent scopes
      #
      module ScopeySexp
        extend BracketExtender
        include CommonSexpInstanceMethods
        BlockAutovivifyingSexp.has_block_at_index(self, 1)
      end

      #
      # For sexps that represent blocks
      #
      module BlockeySexp
        extend BracketExtender
        include CommonSexpInstanceMethods
        include ModuleAutovivifyingSexp
        def each_class &block
          each_node_of_type(:class) do |node, idx|
            ClassySexp[node] unless node.kind_of?(ClassySexp)
            block.call(node,idx)
          end
        end
      end

      #
      # For sexps that represent classes
      #
      module ClassySexp
        include CommonSexpInstanceMethods
        extend BracketExtender
        ScopeHavingSexp.has_scope_at_index(self, 3)

        def add_include str
          include_or_extend :include, str
        end

        def add_extend str
          include_or_extend :extend, str
        end

        def name_sym
          self[1]
        end
        def class_name_underscored
          underscore(name_sym)
        end
        def parent_class_string
          spot = self[2]
          if spot.nil?
            nil
          else
            CommonSexpInstanceMethods[spot]
            spot.to_ruby
          end
        end
        def add_instance_method_sexp sexp
          fail("no") unless :defn === sexp.first
          scope.block!.push sexp
          nil
        end
        def instance_method? name_sym
          !! instance_method(name_sym)
        end
        def instance_method name_sym
          found = scope.block!.find_all_with_index do |node|
            node.kind_of?(Sexp) && :defn == node.first &&
              node[1] == name_sym
          end
          case found.size
          when 0;
            result = nil
          when 1;
            result = found.first.first
            MethodySexp[result] unless result.kind_of?(MethodySexp)
          else
            fail("don't want to deal with this")
          end
          result
        end

      private
        def include_or_extend which, str
          name_sexp = CodeBuilder.module_name_sexp(str)
          call = s(:call, nil, which,
            s(:arglist, CodeBuilder.module_name_sexp(str))
          )
          scope.block!.push call
          nil
        end
      end

      module MethodySexp
        include CommonSexpInstanceMethods
        extend BracketExtender


      end

      #
      # expected only to be used by module sexp ?
      # Don't use this for new stuff.  Constants should not be stored like
      # this.  Look at other modules here
      #
      module RegistersConstants

        def _constants
          @_constants ||= AssArr.new
        end

        def has_constant? name
          _constants.key? name
        end

        def get_constant name
          fail("check has_constant? first -- no such key #{name}") unless
            _constants.key?(name)
          idx = _constants.at_key name
          scope.block![idx]
        end

        def add_constant_strict sexp
          use_name = sexp.constant_basename_symbol
          fail("already has constant #{use_name}. use get_constant().") if
            has_constant? use_name
          next_idx = scope.block!.length
          _constants.push_with_key next_idx, use_name
          scope.block!.push(sexp)
          nil
        end
      end
      Symbols = {
        :module   => { :module => CodeBuilder::ModuleySexp },
        :scope    => { :module => CodeBuilder::ScopeySexp  },
        :block    => { :module => CodeBuilder::BlockeySexp },
        :class    => { :module => CodeBuilder::ClassySexp  },
        :arglist  => true,
        :args     => true,
        :array    => true,
        :attrasgn => true,
        :call     => { :value_index => 2 },
        :class    => { :value_index => 1 },
        :colon2   => true,
        :const    => true,
        :defn     => true,
        :defs     => true,
        :iasgn    => true,
        :if       => true,
        :iter     => true,
        :lasgn    => true,
        :lit      => true,
        :lvar     => true,
        :hash     => true,
        :self     => true,
        :str      => true
      }
    end
  end
end


