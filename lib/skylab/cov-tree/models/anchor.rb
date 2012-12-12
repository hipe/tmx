module Skylab::CovTree

  class Models::Anchor

    attr_reader :dir_pathname

    def relative_path_to short_pathname
      res = nil
      if @sub_path
        res = [ * @sub_path, short_pathname.to_s ].join '/'
      else
        res = short_pathname.to_s
      end
      res
    end

    def sub_anchor
      @sub_anchor ||= begin
        sub_anchor = nil
        if @sub_path
          sub_anchor = @dir_pathname.join @sub_path.join( '/' )
        else
          sub_anchor = @dir_pathname
        end
        sub_anchor
      end
    end

    attr_reader :test_file_short_pathnames

    def tree_combined
      @tree_combined ||= begin

        toc = tree_of_code
        tot = tree_of_tests

        tree = Models::FileNode.combine toc, tot do |node|
          # test files "isomorph" to code files with their last slug
          node.isomorphic_slugs.last
        end

        tree
      end
    end

  protected

    def initialize dir_pathname, sub_path, short_paths
      @dir_pathname = dir_pathname
      @sub_anchor = nil
      @sub_path = sub_path
      @test_file_short_pathnames = short_paths.to_a
    end


    fun = CovTree::FUN
    extname = Autoloader::EXTNAME  # '.rb'
    stop_rx = fun.stop_rx

    define_method :tree_of_code do
      @tree_of_code ||= begin
        stop_rx =~ @dir_pathname.to_s and fail "sanity - anchor is '.' or / ?"
        some_anchor = @dir_pathname.dirname    # the app anchor is the parent
        if @sub_path                           # of the test dir. jump down
          some_anchor = some_anchor.join( @sub_path.join '/' ) # with the sub
        end                                    # path if you've got one.

                                               # find *all* '*.rb' under the
        glob = "#{ some_anchor }/**/*#{ extname }" # this anchor (maybe app
        paths = ::Dir[ glob ]                  # anchor maybe app subdir)

        if ! @sub_path                         # Tricky: filter out all the
          rx = %r{ \A #{ ::Regexp.escape @dir_pathname.to_s } / }x # paths that
          paths.keep_if { |path| rx !~ path }  # were under the test dir (but
        end                                    # this is only nec. when no sub-
                                               # path because test dir itself
                                               # a sub-path.
                                               # Make and clean the tree:
        tree = Models::FileNode.from_paths( paths ) { |n| n.type = :code }
        case tree.children_length
        when 0                                 # @_hack = true
          tree.slug = '(no code)'
        when 1                                 # slough off the empty root node
          tree = tree.children.first
        else
          fail "sanity - not expecting trees with more than one root"
        end
        tree
      end
    end


    define_method :tree_of_tests do
      @tree_of_tests ||= begin
        paths = -> do
          @sub_anchor || sub_anchor # kick :/
          @test_file_short_pathnames.map { |pn| @sub_anchor.join( pn ).to_s }
        end.call
        tree = Models::FileNode.from_paths( paths ) { |n| n.type = :test }
        case tree.children_length
        when 0
          t.slug = '(no tests)'
        when 1
          is_shallow_path = ! (@dir_pathname.to_s.include? tree.path_separator)
          if is_shallow_path
            tree.isomorphic_slugs.push '.'
            anchorpoint = tree
          else
            anchorpoint = tree.find @dir_pathname.dirname.to_s
          end
          1 == anchorpoint.children_length or fail "sanity"
          testdir = anchorpoint.children.first
          anchorpoint.children = testdir.children
          anchorpoint.isomorphic_slugs[0,0] =
            [ "#{ anchorpoint.slug }/#{ testdir.slug }" ] # retain old name
          if ! is_shallow_path                 # *now* we can slough off
            tree = tree.children.first         # the empty root node
          end
        else
          fail "sanity - not expecting test trees with more than one root"
        end
        # hack an association of the two trees if necessary
        if tree.isomorphic_slugs.last != tree_of_code.slug
          tree.isomorphic_slugs.push tree_of_code.slug
        end
        tree
      end
    end
  end
end
