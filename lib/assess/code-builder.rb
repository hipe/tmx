require 'ruby2ruby'
require 'ruby_parser'
require 'assess/uber-alles-array'

module Hipe
  module Assess
    module CodeBuilder
      extend self
      @parser = RubyParser.new
      @ruby2ruby = Ruby2Ruby.new
      class << self
        attr_reader :parser, :ruby2ruby
      end

      #
      # any nodes that want to can register themselves here
      # so that other nodes can refer to them by id.  However this
      # facility is not provided out-of-the-box for sexp classes here.
      #
      Nodes = Array.new
      class << Nodes
        def register obj
          id = length
          self[id] = obj
          id
        end
      end


      def module_name_sexp(str)
        if str.nil?
          nil
        elsif str.include?(':')
          parser.process str
        else
          str.to_sym
        end
      end

      def build_module name, &block
        ModuleSexp.build(name, &block)
      end

      def build_class name, extends=nil, &block
        ClassSexp.build(name, extends, &block)
      end


      #
      # utility modules for adapter libraries to use
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
        ClassBasenameRe = Re = /([^:]+)$/
        def class_basename kls
          Re.match(kls.to_s)[1]
        end
      end

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
          block[idx]
        end

        def add_constant_strict sexp
          use_name = sexp.constant_basename_symbol
          fail("already has constant #{use_name}. use get_constant().") if
            has_constant? use_name
          next_idx = block.size
          _constants.push_with_key next_idx, use_name
          block.push(sexp)
          nil
        end
      end


      #
      # utility classes for adapter modules to use directly or subclass
      # for some reason we don't like overriding the constructors provided
      # by Sexp so .. etc
      #

      class ModuleSexp < Sexp

        def self.build name, &block
          name_sexp = CodeBuilder.module_name_sexp name
          thing = new(:module, name_sexp, s(:scope, s(:block)))
          yield(thing) if block_given?
          thing
        end

        def my_to_ruby
          other = Marshal.load(Marshal.dump(self))
          ruby = CodeBuilder.ruby2ruby.process other
          ruby
        end

        def block
          my_scope = last
          if my_scope.size == 1
            my_scope.push s(:block)
          end
          my_scope[1]
        end
      end

      class ClassSexp < ModuleSexp

        def self.build name, extends, &block
          name_sexp    = CodeBuilder.module_name_sexp name
          extends_sexp = CodeBuilder.module_name_sexp extends
          thing = new(:class, name_sexp, extends_sexp, s(:scope, s(:block)))
          yield(thing) if block_given?
          thing
        end

        def add_include str
          call = s(:call, nil, :include,
            s(:arglist, CodeBuilder.module_name_sexp(str))
          )
          block.push call
          nil
        end
      end
    end
  end
end
