module Skylab::CovTree
  class Models::Anchor < Struct.new(:dir, :test_files)
    def tree_combined
      @tree_combined ||= nil and return @tree_combined
      t = Models::FileNode.combine(tree_of_code, tree_of_tests) { |n| n.isomorphic_slugs.last }
        # test files isomorph to code files with their last slug
      t.slug_dirname = ((@_hack ||= nil) ? dir.dirname : dir.dirname.dirname).to_s
      @tree_combined = t
    end
    def tree_of_code
      @tree_of_code ||= nil and return @tree_of_code
      re = %r{^#{Regexp.escape dir.to_s}/}
      _paths = Dir["#{dir.dirname}/**/*.rb"]
      _paths = _paths.select { |f| re !~ f }
      t = Models::FileNode.from_paths(_paths){ |n| n.type = :code }
      if t.children?
        t = t.find(dir.dirname.to_s) or fail("truncation hack failed")
      else
        @_hack = true
        t.slug = '(no code)'
      end
      @tree_of_code = t
    end
    def tree_of_tests
      @tree_of_tests ||= nil and return @tree_of_tests
      _pp = test_files.map { |f| f.pathname.to_s }
      t = Models::FileNode.from_paths(_pp) { |n| n.type = :test }
      if t.children?
        t = t.find(dir.to_s) or fail("truncation hack failed")
      else
        t.slug = '(no tests)'
      end
      # associate the tests tree (root node) and the code tree by telling
      t.isomorphic_slugs.push tree_of_code.slug # this to the test tree
      @tree_of_tests = t
    end
  end
end
