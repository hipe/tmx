require 'pathname'
require 'skylab/porcelain/tree'

module ::Skylab::CovTree
  class Plumbing::Tree
    extend ::Skylab::Slake::Muxer
    emits :all, :info => :all, :error => :all, :payload => :all

    TEST_DIR_NAMES = %w(test spec features)
    GLOBS = {
      'features' => '*.feature',
      'spec' => '*_spec.rb',
      'test' => '*_spec.rb'
    }

    def initialize path, ctx
      @path = Pathname.new(path || '.')
      @ctx = ctx
      yield self
    end
    def list
      test_file_paths.tap do |paths|
        paths or return
        paths.each { |s| emit(:payload, s) }
        return paths.count
      end
    end
    def run
      @ctx[:list] and return list
      tree
    end
    def test_dir
      if found = TEST_DIR_NAMES.detect{ |s| s == @path.basename.to_s } and @path.exist?
        @_dirname = found
        return @path
      end
      unless found = TEST_DIR_NAMES.detect { |n| @path.join(n).exist? }
        emit(:error, "Couldn't find test directory: #{@path.join "[#{TEST_DIR_NAMES.join('|')}]"}")
        return false
      end
      @_dirname = found
      @path.join(found)
    end
    def test_file_globs
      test_dir = self.test_dir or return false
      glob = GLOBS[@_dirname] or fail("nope: #{@_dirname}")
      [test_dir.join('**').join(glob)]
    end
    def test_file_paths
      globs = test_file_globs or return
      globs.reduce([]){ |m, glob| m.concat(Dir[glob]) }
    end
    def tree
      st = tree_struct or return false
    end
    def tree_struct
      paths = test_file_paths or return false
      tree = ::Skylab::Porcelain::Tree.from_paths paths
      loc = ::Skylab::Porcelain::Tree::Locus.new
      loc.traverse(tree) do |node, meta|
        $stdout.puts "#{loc.prefix(meta)}#{node.key}#{'/' if node.children?}"
      end
      true
    end
  end
end

