require File.expand_path('../../node', __FILE__)
require 'skylab/face/core'

module ::Skylab::CovTree
  class API::Actions::Tree < API::Action

    emits :error, :line_meta, :payload

    attr_accessor :do_list
    def error msg
      emit(:error, msg)
      false
    end
    def initialize params
      @do_list = false
      yield self
      params.each { |k, v| send("#{k}=", v) }
      @path or self.path = '.'
    end
    def invoke # @todo naming
      do_list ? list : tree
    end
    def list
      paths = test_file_paths or return paths
      paths.each { |s| emit(:payload, s) }
      paths.count
    end
    attr_writer :list
    def path= path
      @path = path ? ::Skylab::Face::MyPathname.new(path) : path
    end
    def test_dir
      if @path.exist? and TEST_DIR_NAMES.include?(pnbn = @path.basename.to_s)
        @test_dir_basename = pnbn
        @path.dup
      elsif pnbn = TEST_DIR_NAMES.detect { |n| @path.join(n).exist? }
        @test_dir_basename = pnbn
        @path.join(pnbn)
      else
        error("Couldn't find test directory: #{pre @path.join(TEST_DIR_NAMES.string).pretty}")
      end
    end
    def test_file_globs
      @test_dir = test_dir or return @test_dir
      glob = GLOBS[@test_dir_basename] or fail("nope: #{@_dirname}")
      [@test_dir.join('**').join(glob)]
    end
    def test_file_paths
      globs = test_file_globs or return globs
      globs.reduce([]){ |m, glob| m.concat(Dir[glob]) }
    end
    def code_file_paths
      re = %r{^#{Regexp.escape @test_dir.to_s}/}
      files = Dir["#{@test_dir.dirname}/**/*.rb"]
      files.select { |f| re !~ f }
    end
    def tree_to_render
      tests = test_tree_struct or return false
      if 0 == tests.children_length # try to future-proof it.  careful!
        tests = Node.new(root: true, slug: '(empty test dir)', type: :test)
      else
        tests = tests.find(@test_dir.to_s) or fail("truncation hack failed")
      end
      codes = code_tree_struct or return false
      codes = codes.find(@test_dir.dirname.to_s) or fail("truncation hack failed")
      # tell the tests tree that it follows the codes tree's structure by aliasing it
      tests.aliases = [codes.slug]
      both = Node.combine([codes, tests],
        keymaker: ->(n) { [n.slug, *(n.aliases? ? n.aliases : [])].last } # use the last alias as the comparison key
      )
      both
    end
    def tree
      both = tree_to_render or return both
      loc = ::Skylab::Porcelain::Tree::Locus.new
      loc.traverse(both) do |node, meta|
        meta[:prefix] = loc.prefix(meta)
        meta[:node] = node
        emit(:line_meta, meta)
      end
      true
    end
    def test_tree_struct
      test_files = test_file_paths or return false
      Node.from_paths(test_files) { |node| node[:type] = :test }
    end
    def code_tree_struct
      code_files = code_file_paths or return false
      Node.from_paths(code_files){ |node| node[:type] = :code }
    end
  end
end

