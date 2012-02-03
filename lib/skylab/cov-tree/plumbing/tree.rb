require File.expand_path('../../node', __FILE__)
require 'pathname'

module ::Skylab::CovTree
  class Plumbing::Tree
    extend ::Skylab::Slake::Muxer
    emits :all,
      :payload => :all,   # for lines
      :line_meta => :all, # for lines of tree
      :error => :all

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
      @test_dir = test_dir or return false
      glob = GLOBS[@_dirname] or fail("nope: #{@_dirname}")
      [@test_dir.join('**').join(glob)]
    end
    def test_file_paths
      globs = test_file_globs or return
      globs.reduce([]){ |m, glob| m.concat(Dir[glob]) }
    end
    def code_file_paths
      re = %r{^#{Regexp.escape @test_dir.to_s}/}
      files = Dir["#{@test_dir.dirname}/**/*.rb"]
      files.select { |f| re !~ f }
    end
    def tree
      require 'pp'
      tests = test_tree_struct or return false
      tests = tests.find(@test_dir)
      codes = code_tree_struct or return false
      codes = codes.find(@test_dir.dirname)
      # tell the tests tree that it follows the codes tree's structure by aliasing it
      tests.aliases = [codes.slug]
      both = Node.combine([codes, tests],
                          keymaker: ->(n) { [n.slug, *(n.aliases? ? n.aliases : [])].last }, # use the last alias as the comparison key
                          labelmaker: ->(n) { n.type })
      PP.pp(both)
      exit(1)
      loc = ::Skylab::Porcelain::Tree::Locus.new
      loc.traverse(tests) do |node, meta|
        meta[:prefix] = loc.prefix(meta)
        meta[:node] = node
        emit(:line_meta, meta)
      end
      true
    end
    def test_tree_struct
      test_files = test_file_paths or return false
      Node.from_paths(test_files){ |node| node[:type] = :test }
    end
    def code_tree_struct
      code_files = code_file_paths or return false
      Node.from_paths(code_files){ |node| node[:type] = :code }
    end
  end
end

