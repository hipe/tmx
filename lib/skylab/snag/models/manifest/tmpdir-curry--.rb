module Skylab::Snag

  class Models::Manifest

    class Tmpdir_Curry__ < Agent_

      Entity_[ self, :fields, :dirname, :tmpdir_pathname,
        :is_dry_run, :file_utils, :escape_path_p, :error_p ]

      def execute
        -> do  # #result-block
          prepare or break false
          create_if_not_exist or break false
          self
        end.call
      end

    private

      def prepare
        @escape_path_p ||= IDENTITY_
        true
      end

      def create_if_not_exist
        @tmpdir_pathname.exist? ? true : create
      end

      def create
        -> do  # #result-block
          pn = @tmpdir_pathname
          pn.dirname.exist? or break bork( "won't create #{
            }more than one directory. Parent directory of our tmpdir #{
            }(#{ pn.basename }) must exist: #{ @escape_path_p[ pn.dirname ] }")
          @file_utils.mkdir pn.to_s, noop: @is_dry_run
          true
        end.call
      end

    public

      # the proxy services :/

      def exist?
        @tmpdir_pathname.exist?
      end

      def join x
        @tmpdir_pathname.join x
      end
    end
  end
end
