require 'minitest/autorun'
require 'ruby-debug'
root = File.expand_path('../lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(root) unless $LOAD_PATH.include?(root)
require 'assess'
require 'assess/code-builder'

module Hipe
  module Assess
    WritableDir = RootDir + '/test/writable-temp'
    class CodeBuilderTestCase < MiniTest::Unit::TestCase
      def test_build_basic_class
        cls = CodeBuilder.build_class('Foo::Bar', 'Foo::Bar::Baz') do |cls|
          cls.add_include 'DataMapper::Resource'
        end
        ruby = cls.my_to_ruby

        target = <<-HERE.gsub(/^ {8}/,'').strip
        class Foo::Bar < Foo::Bar::Baz
          include(DataMapper::Resource)
        end
        HERE

        assert_equal ruby, target
      end

      def test_build_another_class
        cls = CodeBuilder.build_class('Foo') do |cls|
          cls.block.push(
           s(:call, nil, :property,
             s(:arglist, s(:lit, :some_prop), s(:const, :Text))
            )
          )
        end
        ruby = cls.my_to_ruby
        target = <<-HERE.gsub(/^ {8}/, '').strip
        class Foo
          property(:some_prop, Text)
        end
        HERE
        assert_equal ruby, target
      end

      def test_whole_shebang
        infile = RootDir + '/test/codebuilder_data/thing.json'
        outfile = RootDir + '/test/writable-temp/genned-model.rb'
        FileUtils.rm(outfile) if File.exist? outfile
        instream = File.open(infile,'r')
        sexp = Commands._generate_datamapper_model_sexp_from_json(
          instream, 'resource'
        )
        outstream = File.open(outfile,'w+')
        outstream.puts sexp.my_to_ruby
        outstream.close
        do_something_with_this_file outfile
      end

      def do_something_with_this_file outfile
        require 'dm-core'
        const_before = Object.constants
        require outfile
        nu =  Object.constants - const_before
        fail("oops") unless nu.size == 1
        mod = Object.const_get(nu[0])
        thing = ["LinkiesLinkiesHref", "LinkiesLinkiesContent", "Linkies",
          "ResourceAuthesque", "LinkiesHref", "LinkiesResource",
          "ResourceResourceSection", "Resource",
          "ResourceResourceAuthesque", "ResourceSection", "LinkiesContent"
        ]
        assert_equal(0 , (thing - mod.constants).size)
        assert_equal(0 , (mod.constants - thing).size)
      end
    end
  end
end
