module Skylab::Snag

  class Library_::Manifest

    class Tmpdir_Curry_ < Funcy_

      MetaHell::FUN.fields[ self, :dirname, :tmpdir_pathname,
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
        @escape_path_p ||= MetaHell::IDENTITY_
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
