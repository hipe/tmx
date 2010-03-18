require 'ruby2ruby'
require 'ruby_parser'
require 'assess'
require 'assess/util/uber-alles-array'
require 'assess/code-builder/support'
require 'assess/code-builder/sexps'

module Hipe
  module Assess
    module CodeBuilder
      extend self
      @parser = RubyParser.new
      @ruby2ruby = Ruby2Ruby.new
      class << self
        attr_reader :parser, :ruby2ruby
      end
      def parse ruby
        parser.process ruby
      end

      def build_file name
        FileSexp.build(name)
      end

      def build_module name, &block
        ModuleSexp.build(name, &block)
      end

      def build_class name, extends=nil, &block
        ClassSexp.build(name, extends, &block)
      end
    end
  end
end
