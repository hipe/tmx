module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_  # read [#016] the git repo narrative for storypoints

      def self.build_repo pathname, listener, & repo_option_p
        pn = self::Resolve__.new( self, pathname, listener ).execute
        pn and new( pn, pathname, listener, & repo_option_p )
      end

      def initialize absolute_pn, focus_dir_absoulte_pn, listener
        @listener = listener
        @absolute_pn = absolute_pn
        @ci_pool_p = -> { init_ci_pool }
        @focus_dir_relpath_pn = focus_dir_absoulte_pn.
          relative_path_from( absolute_pn )
        yield self
        # M-etaHell::F-UN.without_warning { GitViz._lib.grit }  # see [#016]:#as-for-grit
        # @inner = ::Grit::Repo.new absolute_pn.to_path ; nil
      end

      attr_accessor :system_conduit

      def build_hist_tree_bunch  # this is a good starting point for :[#012]
        _hist_tree = self.class::Hist_Tree__.new self, @listener
        _hist_tree.build_bunch
      end

      def get_focus_dir_absolute_pn
        @absolute_pn.join @focus_dir_relpath_pn
      end

      def absolute_pathname
        @absolute_pn
      end

      # ~ for the children - filediffs

      def normal_path_of_file_relpath relpath
        @focus_dir_relpath_pn.join( relpath ).to_s
      end

      def lookup_commit_with_SHA x
        @sparse_matrix.lookup_commit_with_SHA x
      end

      def lookup_commitpoint_index_of_commit ci
        @sparse_matrix.lookup_commitpoint_index_of_ci ci
      end

      # ~ the commit pool

      def SHA_notify sha
        commit_pool.SHA_notify sha
      end
    private
      def commit_pool
        @ci_pool_p[]
      end
      def init_ci_pool
        ci_pool = bld_ci_pool ; @ci_pool_p = -> { ci_pool } ; ci_pool
      end
      def bld_ci_pool
        self.class::Commit_::Pool.new self, @system_conduit, @listener
      end
    public
      def close_the_pool
        @sparse_matrix = commit_pool.close_pool
        @ci_pool_p = -> { raise "the pool's closed" }
        @sparse_matrix && PROCEDE_
      end
      attr_reader :sparse_matrix

      # ~ private helper classes

      class Resolve__  # this looks like a :+[#st-007] tree walk

        def initialize repo_cls, pn, listener
          @listener = listener ; @pn = pn
          @pn.absolute? or raise ::ArgumentError,
            "relative paths are not honored here - #{ pn }"
          @repo_cls = repo_cls ; nil
        end

        def execute
          pn = @pn ; count = 0
          begin
            pn.join( IMPLEMENTATION_DIR_ ).exist? and break
            count += 1
            TOP__ == pn.instance_variable_get( :@path ) and
              break( did_fail = true )
            pn = pn.dirname
          end while true
          @count = count
          did_fail ? when_did_fail : pn
        end
        TOP__ = '/'.freeze
      private
        def when_did_fail
          @listener.maybe_receive_event :repo_root_not_found, :error, :string do
            say_didnt_find_repo_implementation_dir
          end
          DESIST_
        end
        def say_didnt_find_repo_implementation_dir
          "Didn't find #{ IMPLEMENTATION_DIR_ } in this or any parent #{
            }directory (looked in #{ @count } dirs): #{ @pn }"
        end
      end

      class SHA_  # [#016]:#what-is-the-deal-with-SHA's?

        def self.some_instance_from_string sha_s
          MOCK_FRIENDLY_SHA_WHITE_RX__ =~ sha_s or fail "SHA?: #{ sha_s }"
          touch_from_SHA_i sha_s.intern
        end
        MOCK_FRIENDLY_SHA_WHITE_RX__ = /\A[a-z0-9]+\z/
        @cache_h = {}
        class << self
        private
          def touch_from_SHA_i sha_i
            @cache_h.fetch sha_i do
              @cache_h[ sha_i ] = new sha_i
            end
          end
          private :new
        end

        def initialize sha_i
          @SHA_i = sha_i ; freeze
        end
        def as_symbol
          @SHA_i
        end
        def hash
          @SHA_i.hash
        end
        def to_string
          @SHA_i.id2name
        end
      end
    end
  end
end
