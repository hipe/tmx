module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_::Hist_Tree__  # part of [#012]

      def initialize repo, & oes_p
        @on_event_selectively = oes_p
        @repo = repo
      end

      def build_bunch
        self.class::Bunch__.build_bunch self, & @on_event_selectively
      end

      # ~ for the children

      attr_reader :repo

      SILENT_ = nil
    end
  end
end

# :+#tombstone: [#008] `Simple_Agent_` was replaced by [cb] actor
