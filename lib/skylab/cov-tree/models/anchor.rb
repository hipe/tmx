module Skylab::CovTree
  class Models::Anchor < Struct.new(:dir, :test_files)
    def tree_combined
      @tree_combined ||= nil and return @tree_combined
      t = Models::FileNode.combine(tree_of_code, tree_of_tests) { |n| n.isomorphic_slugs.last }
        # test files isomorph to code files with their last slug
      # t.slug_dirname = ((@_hack ||= nil) ? dir.dirname : dir.dirname.dirname).to_s
      @tree_combined = t
    end
    def tree_of_code
      @tree_of_code ||= nil and return @tree_of_code
      re = %r{^#{Regexp.escape dir.to_s}/}
      _paths = Dir["#{dir.dirname}/**/*.rb"]
      _paths = _paths.select { |f| re !~ f }
      t = Models::FileNode.from_paths(_paths){ |n| n.type = :code }
      case t.children_length
      when 0 ; t.slug = '(no code)' ; @_hack = true
      when 1 ; t = t.children.first # slough off the uninteresting base
      else   ; fail('this was unexpected')
      end
      @tree_of_code = t
    end
    def tree_of_tests
      @tree_of_tests ||= nil and return @tree_of_tests
      _pp = test_files.map { |f| f.pathname.to_s }
      t = Models::FileNode.from_paths(_pp) { |n| n.type = :test }
      case t.children_length
      when 0 ; t.slug = '(no tests)'
      when 1 ; shallow = ! dir.to_s.index(t.path_separator)
             ; shallow and t.isomorphic_slugs.push '.'
             ; anchorpoint = shallow ? t : t.find(dir.dirname.to_s)
             ; anchorpoint.children_length == 1 or fail('this was unexpected')
             ; testdir = anchorpoint.children.first
             ; anchorpoint.children = testdir.children
             ; anchorpoint.isomorphic_slugs[0,0] = ["#{anchorpoint.slug}/#{testdir.slug}"] # retain old name
             ; shallow or t = t.children.first # *now* slough off the uninteresting base
      else   ; fail('this was unexpected')
      end
      # hack an association of the two trees if necessary
      t.isomorphic_slugs.last == tree_of_code.slug or t.isomorphic_slugs.push(tree_of_code.slug)
      @tree_of_tests = t
    end
  end
end
