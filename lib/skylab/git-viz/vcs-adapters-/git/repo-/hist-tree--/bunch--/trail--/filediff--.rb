module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_::Hist_Tree__

      class Bunch__::Trail__::Filediff__

        def initialize sha
          @SHA = sha ; nil
        end

        attr_reader :commitpoint_index, :counts, :SHA

        def set_commitpoint_index idx
          @commitpoint_index = idx ; nil
        end

        def set_counts_and_finish counts
          @counts = counts
          freeze ; nil
        end

        def finish_filediff__ trail, & oes_p
          Finish_Filediff___.new( trail, self, & oes_p ).__finish_filediff
        end

        class Finish_Filediff___

          def initialize trail, filediff, & oes_p

            @filediff = filediff
            @on_event_selectively = oes_p
            @repo = trail.repo
            @trail = trail
          end

          def __finish_filediff
            @ci = @repo.lookup_commit_with_SHA @filediff.SHA
            @norm_path = @repo.normal_path_of_file_relpath @trail.file_relpath
            @counts = @ci.lookup_any_filediff_counts_for_normpath @norm_path
            @counts ? when_yes : when_no
          end

        private

          def when_yes
            _cpi = @repo.lookup_commitpoint_index_of_commit @ci
            @filediff.set_commitpoint_index _cpi
            @filediff.set_counts_and_finish @counts
            PROCEDE_
          end

          def when_no  # this is here to catch [#035] this issue

            fd = @filediff ; norm_path = @norm_path

            @on_event_selectively.call(
                :info, :expression, :omitting_informational_commitpoint ) do | y |

              y << "'#{ fd.SHA.to_string }' appears only to be #{
                }informational in regards to #{ norm_path }"
            end

            @trail.remove_filediff @filediff

            PROCEDE_
          end
        end
      end
    end
  end
end
