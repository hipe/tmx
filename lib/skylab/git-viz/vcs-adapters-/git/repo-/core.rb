module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_  # read [#016] the git repo narrative for storypoints

      class << self

        def build_repo pathname, oes_p, & repo_option_p

          pn = Produce_pathname___[ self, pathname, & oes_p ]
          pn and begin
            new( pn, pathname, oes_p, & repo_option_p )
          end
        end
      end  # >>

      def initialize absolute_pn, focus_dir_absoulte_pn, oes_p

        @absolute_pn = absolute_pn

        @ci_pool_p = -> { __init_ci_pool }

        @focus_dir_relpath_pn = focus_dir_absoulte_pn.
          relative_path_from( absolute_pn )

        @on_event_selectively = oes_p

        yield self
        # M-etaHell::F-UN.without_warning { GitViz_.lib_.grit }  # see [#016]:#as-for-grit
        # @inner = ::Grit::Repo.new absolute_pn.to_path ; nil
      end

      attr_accessor :system_conduit

      def build_hist_tree_bunch  # this is a good starting point for :[#012]
        _hist_tree = self.class::Hist_Tree__.new self, & @on_event_selectively
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
        _commit_pool.SHA_notify sha
      end

      def close_the_pool
        @sparse_matrix = _commit_pool.close_pool
        @ci_pool_p = -> { raise "the pool's closed" }
        @sparse_matrix && ACHIEVED_
      end

      attr_reader :sparse_matrix

      def _commit_pool
        @ci_pool_p[]
      end

      def __init_ci_pool
        ci_pool = __build_ci_pool
        @ci_pool_p = -> { ci_pool }
        ci_pool
      end

      def __build_ci_pool
        self.class::Commit_::Pool.new self, @system_conduit, & @on_event_selectively
      end


      Produce_pathname___ = -> repo_cls, pathname, & oes_p do

        # we gotta use this and not :+[#hl-176] (tree walk) while #open [#004]

        if SEP_BYTE___ != pathname.instance_variable_get( :@path ).getbyte( 0 )
          # use of pathname is "temporary"

          raise ::ArgumentError, "relative paths are not honored here - #{ pathname.to_path }"
        end

        filename = IMPLEMENTATION_DIR_
        num_times_looked = 1
        pn = pathname
        begin
          if pn.join( filename ).exist?
            found = pn
            break
          end
          pn_ = pn.dirname
          if pn_ == pn
            break
          end
          num_times_looked += 1
          pn = pn_
          redo
        end while nil

        found or begin

          oes_p.call :error, :repo_root_not_found do

            Callback_::Event.inline_not_OK_with :repo_root_not_found,
                :filename, filename, :num_times_looked, num_times_looked,
                :path, pathname.to_path do | y, o |

              y << "Didn't find '#{ o.filename }' #{
               }entry in this or any parent directory #{
                }(looked in #{ o.num_times_looked } dirs): #{ pth o.path }"
            end
          end
          UNABLE_
        end
      end

      SEP_BYTE___ = ::File::SEPARATOR.getbyte 0

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
