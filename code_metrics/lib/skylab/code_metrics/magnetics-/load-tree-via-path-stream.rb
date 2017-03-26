module Skylab::CodeMetrics

  class Magnetics_::LoadTree_via_PathStream < Common_::Dyadic

    # "load tree" in summary:
    #   - a tree of "abstract names"
    #   - that flattens itself "intelligently"
    #   - and "tails" each element
    #
    # we explain each of these points one by one below.
    #
    # the load tree's responsibility is to take as input the stream of
    # paths as expanded by the user's path arguments (after expansion
    # through globbing), and in effect present them in a way that is
    # amenable to loading.
    #
    # what this means specifically carries with it strong assumptions
    # about how we (auto) load, but longer term we hope that this general
    # algorithm can apply towards "load adapters" for code trees outside
    # those that use [co] autoloading.


    # ## what we mean by "abstract names"
    #
    # the elements of a filesystem path ("/foo/bar.file") each correspond
    # to what we call a filesystem "entry" (a directory called "foo",
    # a file called "bar.file", these are "entries").
    #
    # as is our habit, we tend to place a strong correspondence between
    # an "asset file"'s name is what code it contains, in regards to the
    # constant it defines, etc. (formalized at [#co-024.2].)
    #
    # as such, when we schlurp the user-argument-derived paths into this
    # tree, we want to think of the resulting nodes not as representing
    # filesystem entries, but rather as just being abstract "names" that
    # could be used for purposes other than referring to files.
    #
    # as it will work out, the names we store in the tree will be strings
    # derived quite plainly from the filesystem entry names (with directory
    # names as-is and files with the extension removed), but we want to
    # encourage this more "abstract thinking" of them..
    #
    # specifically we will use our autoloader `const_reduce` on the names,
    # but we may abtract this implementation to elsewhere..


    # ## "intelligently"
    #
    # it it certainly the case that our own autoloady architecture is
    # resilient enough not to need this, but imagine we don't have it:
    #
    #     lib/my_gem/foo/bar.rb
    #     lib/my_gem/foo.rb
    #
    # in a scenario like the above, it might be the case that "bar"
    # expects "foo" to be loaded when it is loaded (but not the other
    # way around).
    #
    # we would solve for this by flattening the tree ("traversing" it)
    # in a "pre-order" order. (see wikipedia re: tree traversal.)
    #
    # in the future we might want this to be opt-in..


    # ## "tails" each element
    #
    # this simply means that we "normalize" each path in the stream
    # by trucating it against an assumed common "head". what?
    #
    #     /gobbledey-gook/fiz-buz.1.0.1/foo/bar.kd
    #     /gobbledey-gook/fiz-buz.1.0.1/baz.kd
    #
    # in the above (let's say) the interesting parts are just the
    # "foo/bar" and "baz". the leading "goobledey-gook [etc]" is what
    # we call the "head"

    # -
      def initialize path_st, head_path, & p

        @__path_tailer = Home_::Models_::Path::Path_tailerer[ head_path ]

        @_PathScanner = Home_::Mondrian_[]::PathScanner
        @_Tree = Home_.lib_.basic::Tree::Mutable::Frugal

        @__listener = p

        @head_path = head_path
        @path_stream = path_st
      end

      def execute

        @__root = @_Tree.new

        if __index_path
          LoadTree___.new remove_instance_variable :@__root
        end
      end

      def __index_path

        ok = true

        tailer = remove_instance_variable :@__path_tailer

        st = remove_instance_variable :@path_stream
        begin
          path = st.gets
          path || break
          tail = tailer.call path do
            __when_tailer_fail path
          end
          if ! tail
            ok = tail
            break
          end

          en = ::File.extname tail
          if en.length.zero?
            _use_path = tail
          else
            _use_path = tail[ 0 ... -en.length ]
          end

          scn = @_PathScanner.via _use_path

          if ! scn.no_unparsed_exists  # ..
            __schlurp_into_tree scn
          end

          redo
        end while above
        ok
      end

      def __when_tailer_fail path

        msg = "path expanded by input must but did not start with #{
          }#{ @head_path.inspect } - #{ path }"
        p = @__listener
        if p
          p.call :error, :expression, :blah_blah do |y|
            y << msg
          end
          UNABLE_
        else
          raise msg
        end
      end

      def __schlurp_into_tree scn  # assume some

        tree = @__root

        begin
          slug = scn.gets_one
          _tree_ = tree.touch slug do
            @_Tree.new slug
          end
          scn.no_unparsed_exists && break
          tree = _tree_
          redo
        end while above
        NIL
      end
    # -
    # ==

    class LoadTree___

      def initialize tree
        @_tree = tree
      end

      def to_pre_order_normal_path_stream
        @_tree.to_pre_order_normal_path_stream
      end

      def has_children
        @_tree.children_count.nonzero?
      end
    end

    # ==
  end
end
# #born for mondrian
