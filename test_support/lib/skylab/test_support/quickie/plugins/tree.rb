module Skylab::TestSupport

  module Quickie

    class Plugins::Tree

      def initialize
      end

      if false
      def initialize adapter
        @fuzzy_flag = adapter.build_fuzzy_flag %w( -tree )
        @adapter = adapter
      end

      def opts_moniker
        @fuzzy_flag.some_opts_moniker
      end

      def args_moniker
      end
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "like -list but as a tree (experimental)"
        y << "(mutually exclusive with -list)"
      end

      if false
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

        io = @adapter.paystream
        _a = @adapter.services.get_test_path_array

        tree = Home_.lib_.basic::Tree.via :paths, _a
        path_s, tree_ = condense_stem tree
        if path_s
          io.puts path_s
          tree = tree_
        end
        st = tree.to_classified_stream_for( :text )
        x = st.gets
        if ! path_s
          x.node.slug and fail "what: #{ x.node.slug }"
        end
        while (( card = st.gets ))
          io.puts "#{ card.prefix_string }#{ card.node.slug }"
        end
        NIL_
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
end
