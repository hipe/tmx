module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_::Commit_::Rink_

      def self.build_rink ci_a  # must be frozen
        if ci_a.length.zero?
          DESIST_
        else
          new ci_a
        end
      end

      def initialize ci_a
        ci_a.frozen? or raise ::ArgumentError, "construct rink with frozen a"
        @ci_a = ci_a
        @index_set = GitViz_.lib_.set.new ci_a.length.times.to_a
        init_index_by_SHA
        init_index_for_X_axis ; nil
      end
    private
      def init_index_by_SHA
        @SHA_to_d_h = ::Hash[ @ci_a.each_with_index.map do |ci, d|
          [ ci.SHA.hash, d ]
        end ].freeze ; nil
      end
      def init_index_for_X_axis
        @X_axis_order_d_a = @index_set.sort_by do |d|
          @ci_a.fetch( d ).author_datetime
        end
        @SHA_to_commitpoint_index_h = ::Hash[
          @X_axis_order_d_a.each_with_index.map do |internal_d, order_d|
            [ @ci_a.fetch( internal_d ).SHA.hash, order_d ]
          end ] ; nil
      end
    public

      def commitpoint_count
        @ci_a.length
      end

      def lookup_commit_with_SHA sha
        @ci_a.fetch @SHA_to_d_h.fetch sha.hash
      end

      def lookup_commitpoint_index_of_ci ci
        @SHA_to_commitpoint_index_h.fetch ci.SHA.hash
      end
    end
  end
end
