module Skylab::TestSupport

  module Quickie

    class Plugins::Tree

      def initialize svc
        @fuzzy_flag = svc.build_fuzzy_flag %w( -tree )
        @svc = svc
      end

      def opts_moniker
        @fuzzy_flag.some_opts_moniker
      end

      def args_moniker
      end

      def desc y
        y << "like -list but as a tree (experimental)"
        y << "(mutually exclusive with -list)"
        nil
      end

      def prepare sig
        idx = @fuzzy_flag.any_first_index_in_input sig
        if idx
          sig.nilify_input_element_at_index idx
          sig.rely :CULLED_TEST_FILES
          sig.carry :CULLED_TEST_FILES, :FINISHED
          sig
        end
      end

      def culled_test_files_eventpoint_notify
        io = @svc.paystream
        _a = @svc.get_test_path_a
        tree = QuicLib_::Tree[].from :paths, _a
        path_s, tree_ = condense_stem tree
        if path_s
          io.puts path_s
          tree = tree_
        end
        scn = tree.get_traversal_stream
        x = scn.gets
        if ! path_s
          x.node.any_slug and fail "what: #{ x.node.any_slug }"
        end
        while (( card = scn.gets ))
          io.puts "#{ card.prefix[] }#{ card.node.any_slug }"
        end
        nil
      end

    private

      def condense_stem tree
        slug_a = nil
        while 1 == tree.children_count
          tree_ = tree.fetch_only_child
          ( slug_a ||= [] ).push tree_.slug
          tree = tree_
        end
        if slug_a
          [ slug_a * tree.path_separator, tree ]
        end
      end
    end
  end
end
