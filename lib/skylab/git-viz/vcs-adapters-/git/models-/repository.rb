module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Repository  # [#016]..

      class << self

        def new_via_path path, sys_cond=GitViz_.lib_.open3, & oes_p
          new_via_pathname ::Pathname.new( path ), sys_cond, & oes_p
        end

        def new_via_pathname interest_pn, sys_cond, & oes_p  # while #open [#004]

          repo_pn = Find_repository_pathname___[ self, interest_pn, & oes_p ]
          repo_pn and begin
            new interest_pn, repo_pn, sys_cond, & oes_p
          end
        end
      end  # >>

      def initialize interest_pn, repo_pn, sys_cond, & oes_p

        @on_event_selectively = oes_p

        @path = repo_pn.to_path

        @pn_ = repo_pn

        @relative_path_of_interest =
          interest_pn.relative_path_from( repo_pn ).to_path

        @system_conduit = sys_cond

        # M-etaHell::F-UN.without_warning { GitViz_.lib_.grit }  # see [#016]:#as-for-grit
        # @inner = ::Grit::Repo.new absolute_pn.to_path ; nil
      end

      attr_reader :pn_, :path, :relative_path_of_interest

      def fetch_commit_via_identifier id_s, & oes_p

        oes_p ||= @on_event_selectively

        Models_::Commit.fetch_via_identifier__ id_s, self, & oes_p
      end

      def repo_popen_3_ * s_a

        s_a.unshift GIT_EXE_

        if ! ::Hash.try_convert( s_a.last )
          s_a.push chdir: @path
        end

        @system_conduit.popen3( * s_a )
      end

      def vendor_program_name  # :+#public-API
        GIT_EXE_
      end

      Find_repository_pathname___ = -> repo_cls, pathname, & oes_p do

        # we gotta use this and not :+[#sy-018] (tree walk) while #open [#004]

        if SEP_BYTE___ != pathname.instance_variable_get( :@path ).getbyte( 0 )
          # use of pathname is "temporary"

          raise ::ArgumentError, "relative paths are not honored here - #{ pathname.to_path }"
        end

        filename = VENDOR_DIR_
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

    end
  end
end
# :+#tombstone: [#008] `Simple_Agent_` was replaced by [cb] actor
