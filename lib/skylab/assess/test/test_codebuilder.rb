require File.expand_path('./support.rb',File.dirname(__FILE__))
require 'assess/code-builder'

module Hipe
  module Assess
    class CodeBuilderTestCase < MiniTest::Unit::TestCase
      def test_build_basic_class_1_
        cls = CodeBuilder.build_class('Foo::Bar', 'Foo::Bar::Baz') do |cls|
          cls.add_include 'DataMapper::Resource'
        end
        ruby = cls.to_ruby

        target = <<-HERE.gsub(/^ {8}/,'').strip
        class Foo::Bar < Foo::Bar::Baz
          include(DataMapper::Resource)
        end
        HERE

        assert_equal ruby, target
      end

      def test_build_another_class_2_
        cls = CodeBuilder.build_class('Foo') do |cls|
          cls.scope.block!.push(
           s(:call, nil, :property,
             s(:arglist, s(:lit, :some_prop), s(:const, :Text))
            )
          )
        end
        ruby = cls.to_ruby
        target = <<-HERE.gsub(/^ {8}/, '').strip
        class Foo
          property(:some_prop, Text)
        end
        HERE
        assert_equal ruby, target
      end

      def test_whole_shebang_3_
        infile = RootDir + '/test/codebuilder_data/thing.json'
        tmpdir = FrameworkCommon.empty_tmpdir_for!("model-gen")
        file = File.join(tmpdir, 'genned-model.rb')
        Cmd.ui_push
        Commands.invoke(['schema', 'datamapper',
          'resource', 'whatever', infile
        ])
        tmpout_model = File.join(tmpdir, 'genned-model.rb')
        str = Cmd.ui_pop_read
        File.open(tmpout_model,'w+'){|fh| fh.write(str)}
        assert_model_file tmpout_model
      end

      def assert_model_file outfile
        require 'dm-core'
        const_before = Object.constants
        require outfile
        nu =  Object.constants - const_before
        fail("oops") unless nu.size == 1
        mod = Object.const_get(nu[0])
        tgt = %w(
          ModelCommon
          Resource
          LinkiesResource
          ResourceSection
          Linkies
          LinkiesHref
          LinkiesContent
          ResourceAuthesque
        )
        assert_equal_set tgt, mod.constants, "generated classes"
      end
    end
  end
end
