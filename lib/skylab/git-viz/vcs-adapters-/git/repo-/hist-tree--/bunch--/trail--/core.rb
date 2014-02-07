module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_::Hist_Tree__

      class Bunch__::Trail__

        def self.begin bunch, line, listener
          new( bunch, line, listener ).begin
        end

        def self.finish bunch, trail, listener
          self::Finish__[ bunch, trail, listener ]
        end

        def initialize bunch, line, listener
          @file_relpath = line  # relative to anywhere
          @filediff_a = nil
          @listener_p = -> { listener }
          @repo_p = -> { bunch.repo }
        end

        def begin
          Begin__.new( self, @listener_p[] ).execute
        end

        def to_tree_path
          @file_relpath
        end

        # ~ for the children

        attr_reader :file_relpath

        def repo
          @repo_p[]
        end

        def build_filediff sha
          self.class::Filediff__.new sha
        end

        def add_filediff fd
          (( @filediff_a ||= [] )) << fd ; nil
        end

        def remove_filediff filediff
          p = filediff.SHA.hash.method :==
          idx = @filediff_a.index do |fd|
            p[ fd.SHA.hash ]
          end or self._SANITY
          @filediff_a[ idx, 1 ] = EMPTY_A_
          SILENT_
        end

        def finish
          @listener_p = @repo_p = nil
          freeze  # or not, whatever
          PROCEDE_
        end

        def get_any_nonzero_count_filediff_scanner
          @filediff_a and bld_fd_scanner
        end
      private
        def bld_fd_scanner
          d = -1 ; last = @filediff_a.length - 1
          Scn_.new do
            d < last and @filediff_a.fetch d += 1
          end
        end
      public

        def get_filediff_scanner
          d = last = nil
          GitViz::Lib_::Power_Scanner[ :init, -> do
            d = -1 ; last = ( @filediff_a ? ( @filediff_a.length - 1 ) : -1 )
          end, :gets, -> do
            d < last and @filediff_a.fetch d += 1
          end ]
        end
      end
    end
  end
end
