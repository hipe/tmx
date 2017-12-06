module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Commit  # see [#009]

      class << self

        def fetch_via_identifier__ id_s, repo, & x_p

          Commit_::Magnetics_::Commit_via_Identifier_and_Repository.call(
            id_s, repo, & x_p )
        end

        def get_base_command_

          [ GIT_EXE_, * BASE_CMD_ ]
        end
      end  # >>

      def initialize & edit_p
        instance_exec( & edit_p )
      end

      def members
        [ :author_datetime, :filechanges, :SHA, :to_filechange_stream ]
      end

      attr_accessor :author_datetime, :filechanges, :SHA

      def fetch_filechange_via_end_path path

        filec = @filechanges.detect do | fc |

          path == fc.end_path
        end

        if filec
          filec
        elsif block_given?
          yield
        else
          raise ::KeyError, __say_no_such_FC( path )
        end
      end

      def __say_no_such_FC path
        "no such filechange whose end path is #{ path.inspect }"
      end

      def to_filechange_stream
        Stream_[ @filechanges ]
      end

      BASE_CMD_ = %w( show --find-renames --numstat --pretty=tformat:%H%n%ai )
        # :[#012]:#the-git-show-command

      Commit_ = self
    end
  end
end
