require File.expand_path('../../node', __FILE__)
require 'pathname'

module ::Skylab::CovTree
  class API::Actions::Tree
    extend ::Skylab::PubSub::Emitter
    emits :all,
      :payload => :all,   # for lines
      :line_meta => :all, # for lines of tree
      :error => :all

    def error msg
      emit(:error, msg)
      false
    end
    def initialize params
      yield self
      params.each { |k, v| send("#{k}=", v) }
      @path or self.path = '.'
    end
    def invoke
      (@list ||= nil) and return list
      tree
    end
    def list
      test_file_paths.tap do |paths|
        paths or return
        paths.each { |s| emit(:payload, s) }
        return paths.count
      end
    end
    attr_writer :list
    def path= path
      @path = path ? Pathname.new(path) : path
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
    def tree_to_render
      tests = test_tree_struct or return false
      tests = tests.find(@test_dir)
      codes = code_tree_struct or return false
      codes = codes.find(@test_dir.dirname)
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
      Node.from_paths(test_files){ |node| node[:type] = :test }
    end
    def code_tree_struct
      code_files = code_file_paths or return false
      Node.from_paths(code_files){ |node| node[:type] = :code }
    end
  end
end

