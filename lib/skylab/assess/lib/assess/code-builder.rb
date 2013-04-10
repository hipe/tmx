require 'ruby2ruby'
require 'ruby_parser'
require 'tmpdir'
require 'assess'
require 'assess/util/uber-alles-array'
me = File.dirname(__FILE__) + '/code-builder'
require me+'/core.rb'
require me+'/common-sexp-instance-methods.rb'
require me+'/sexp-support.rb'
require me+'/file-writer.rb'
require me+'/file-sexp.rb'
require me+'/sexps.rb'

module Hipe
  module Assess
    module CodeBuilder
      extend self
      @parser = RubyParser.new
      @ruby2ruby = Ruby2Ruby.new

      attr_reader :parser, :ruby2ruby

      def parse ruby
        parser.process ruby
      end

      def create_or_get_file_sexp name
        FileSexp.create_or_get_from_path(name)
      end

      def get_file_sexp path
        FileSexp.get_from_path(path)
      end

      def create_or_get_folder path
        require 'assess/code-builder/folder'
        Folder.create_or_get path
      end

      def build_module name, &block
        ModuleSexp.build(name, &block)
      end

      def build_class name, extends=nil, &block
        ClassSexp.build(name, extends, &block)
      end

      def tmpdir
        @tmpdir ||= new_tmpdir
      end

      def new_tmpdir
        Dir.mktmpdir('hipe-assess')
      end

      def to_sexp mixed
        if mixed.kind_of?(Sexp)
          mixed
        elsif mixed.respond_to?(:to_sexp)
          mixed.to_sexp
        elsif mixed.kind_of?(String)
          sexp = parser.process mixed
          CommonSexpInstanceMethods[sexp]
          sexp.enhance_sexp_node!
          sexp
        else
          fail("Can't figure out how to get sexp from #{mixed.inspect}")
        end
      end
    end
  end
end
