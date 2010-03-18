module Hipe
  module Assess
    module CodeBuilder

      #
      # this puppy defines an experimental collection of modules
      # based around scopes, modules, classes, blocks, etc that
      # is supposed to make it easier and more readable to alter
      # dynamically a parse tree
      #


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
          str.to_sym
        end
      end


      #
      # a grab bag of the typical useful stuff
      #
      module AdapterInstanceMethods
        def camelize underscores
          underscores.gsub(/_([a-z]?)/){$1.upcase}
        end
        def titleize str
          str.gsub(/\A(.?)/){$1.upcase}
        end
        def underscore str
          str.gsub(/([a-z])(?=[A-Z])/){ "#{$1.downcase}_" }.downcase
        end
        def assert_type param_name, thing, type
          unless thing.kind_of? type
            meth = method_name_from_call_stack_item caller[0]
            msg = ("#{meth} - #{param_name} must be #{type}, had"<<
              " #{thing.class}")
            fail(msg)
          end
          nil
        end
        MethodNameRe = /`([^']+)'\Z/
        def method_name_from_call_stack_item row
          MethodNameRe.match(row)[0]
        end
        def class_basename kls
          Assess.class_basename kls
        end
        def flail *args
          raise UserFail.new(*args)
        end
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
        include AdapterInstanceMethods
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
        # just for debugging
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
      end

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
        def self.has_block_at_index(mod, idx)
          if mod.instance_methods.include? "block_index"
            fail("uh-oh")
          end
          mod.send(:define_method, :block_index){idx}
          mod.send(:include, self)
        end

        def block!
          if block_index >= length
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
        include CommonSexpInstanceMethods

        def module! name_sym
          them = find_all_with_index do |node|
            node.kind_of?(Sexp) && node[0]==:module && node[1]==name_sym
          end
          case them.size
          when 0;
            result = CodeBuilder.build_module(name_sym)
            block.push result
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
      end

      #
      # For sexps that represent classes
      #
      module ClassySexp
        include CommonSexpInstanceMethods
        extend BracketExtender
        ScopeHavingSexp.has_scope_at_index(self, 3)

        def add_include str
          call = s(:call, nil, :include,
            s(:arglist, CodeBuilder.module_name_sexp(str))
          )
          scope.block!.push call
          nil
        end
        def name_sym
          self[1]
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
    end
  end
end


