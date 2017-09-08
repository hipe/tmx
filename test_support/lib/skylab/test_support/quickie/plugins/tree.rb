module Skylab::TestSupport

  module Quickie

    class Plugins::Tree

      def initialize
        o = yield  # microservice
        @_narrator = o.argument_scanner_narrator
        @_listener = o.listener
        @_shared_datapoint_store = o
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "like -list but as a tree (experimental)"
        y << "(mutually exclusive with -list)"
      end

      def parse_argument_scanner_head feat
        @_narrator.advance_past_match feat.feature_match  # it's a flag - nothing to do
      end

      def release_agent_profile
        Eventpoint_::AgentProfile.define do |o|
          o.must_transition_from_to :files_stream, :finished
        end
      end

      def invoke _

        _path_st = @_shared_datapoint_store.release_test_file_path_streamer_.call

        tree = Home_.lib_.basic::Tree.via :paths, _path_st
        p = nil ; path = nil ; st = nil

        main = -> do
          card = st.gets
          if card
            "#{ card.prefix_string }#{ card.node.slug }"
          end
        end

        init = -> do
          st = tree.to_classified_stream_for :text
          x = st.gets
          if ! path
            x.node.slug and fail "what: #{ x.node.slug }"
          end
          p = main
          p[]
        end

        p = -> do
          path, tree_ = Condense_stem___[ tree ]
          p = init
          if path
            tree = tree_
            path
          else
            p[]
          end
        end

        _st = Common_.stream do
          p[]
        end

        Responses_::FinalResult[ _st ]
      end

      # ==

      Condense_stem___ = -> tree do
        slugs = nil
        while 1 == tree.children_count
          tree_ = tree.fetch_only_child
          ( slugs ||= [] ).push tree_.slug
          tree = tree_
        end
        if slugs
          [ slugs * tree.path_separator, tree ]
        end
      end

      # ==

      # ==
    end
  end
end
# #history: superficial but full rewrite for modernization
