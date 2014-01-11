module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_

      class Commit_

        class << self
          def build_ci repo, sha, lstnr, & p
            self::Build__.call repo, sha, lstnr, & p
          end
          def new_writable sha
            self::Writable__.new self, sha
          end
        end

        class Writable__ < self
          def initialize ci_cls, sha
            @ci_cls = ci_cls ; @file_numstat_h = { } ; @SHA = sha ; nil
          end
          def set_author_datetime dt
            @author_datetime = dt ; nil
          end
          def add_numstat_entry inserts_d_s, deletes_d_s, norm_path
            @file_numstat_h[ norm_path ] =
              File_Numstat__[ inserts_d_s.to_i, deletes_d_s.to_i ].freeze
            nil
          end
          def finish_write
            @file_numstat_h.freeze
            r = @ci_cls.new @SHA, @author_datetime, @file_numstat_h
            @author_datetime = @file_numstat_h = nil ; r
          end
        end

        File_Numstat__ = ::Struct.new :num_insertions, :num_deletions

        def initialize sha, author_dt, file_numstat_h
          @author_datetime = author_dt
          @file_numstat_h = file_numstat_h
          @SHA = sha
          freeze
        end

        attr_reader :author_datetime, :SHA

        def lookup_filediff_counts_for_normpath normpath
          @file_numstat_h.fetch normpath do
            raise ::KeyError, "(corrupt model?) #{
              } #{ normpath } is not a part of commit #{
               }'#{ @SHA.to_string }'#{ say_known_files }"
          end
        end
      private
        def say_known_files  # :+[#it-001] summarization
          if ( 1..5 ).include? @file_numstat_h.length
            ". known files:(#{ @file_numstat_h.keys * ', ' })"
          else
            " (of #{ @file_numstat_h.length } files affected by that commit)"
          end
        end

        class Pool
          def initialize repo, sys_cond, listener
            @cache_h = {} ; @commit_class = repo.class::Commit_
            @listener = listener ; @repo = repo ; @system_conduit = sys_cond
          end
          def SHA_notify sha
            r = true
            @cache_h.fetch sha do |hash_key|
              ci = rslv_any_ci sha
              if ci
                @cache_h[ hash_key ] = ci
              else
                r = ci
              end
            end
            r
          end
        private
          def rslv_any_ci sha
            @commit_class.build_ci @repo, sha, @listener do |ci|
              ci.set_system_conduit @system_conduit
            end
          end
        public
          def close_pool
            a = @cache_h.values.freeze ; @cache_h = :_closed_
            @commit_class::Rink_.build_rink a
          end
        end
      end
    end
  end
end
