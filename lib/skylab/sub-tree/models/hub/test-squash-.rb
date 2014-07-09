module Skylab::SubTree

  class Models::Hub

    class Test_squash_  # the central thesis of this whole thing is that
      # we hold a test tree up to a code tree and make it "line up" and
      # see what the differences are by merging the two trees while
      # maintaining their differences. the trees start out as isomorphic
      # with lists of filesystem paths, but to make them "line up" we have
      # to "squash" the test folder itself (a monadic stem node) out of the
      # picture, and hold the remaining tree up agains the "hub" node, or
      # parent of the test tree. it makes more sense if you use the "-tct"
      # option to see the two trees that go into making the final tree.

      Lib_::Funcy_globless[ self ]

      Entity_[ self, :fields, :app_hub_pn, :test_dir_pn, :tree ]

      def execute
        @test_dir_path_is_monadic = ! @test_dir_pn.to_s.include?( SEP_ )
        if @test_dir_path_is_monadic
          # argument path is e.g "test" in the cwd in which
          # case the 'c-odeish' key for this node is also cwd. it is "near"
          truncate_and_frobulate_near_test_tree
        else
          truncate_and_frobulate_deep_test_tree
        end
      end

    private

      def get_is_monadic_path
        ! @test_dir_pn.to_s.include? SEP_
      end

      def truncate_and_frobulate_near_test_tree
        # the topmost nodes of trees never have a name of their own out of
        # the box, because it is one tree generated from a possibly disparate
        # list of paths, hence we need to add a name now.
        @tree.add_isomorphic_key_with_metakey DOT_, :codeish
        frobulate_common @tree
        @tree
      end

      def truncate_and_frobulate_deep_test_tree
        # test_dir_pn is e.g "foo/bar/test" OR EVEN "./test" !
        hub = @tree.fetch @app_hub_pn.to_s  # app hub pn is always dirname
        prev_slug = hub.slug
        frobulate_common hub
        # this is the most important line in the whole book - without this,
        # the merge does not see an isomophicism at this, the hub node!:
        hub.index_isomorphic_key_with_metakey prev_slug, :codeish
        res = @tree.fetch_only_child
        # when you have a deep path, you want to keep the tree as deep
        # even though it's stemmy. but the topmost node has no name..
        res
      end

      def frobulate_common hub
        # this is step 1 of "hiccuping" the test folder up into its parent
        # node: we give the parent node a moniker slug that reflects this:
        hub.prepend_isomorphic_key(
          "#{ hub.slug } [ & #{ hub.fetch_only_child.slug } ]" )
        # step 2 is "sqaushing" the child node, eliminating it in the
        # stem chain entirely, whereby the parent gets child's children.
        # this is also the most important line in the whole book.
        hub.squash_only_child
        nil
      end
    end
  end
end
