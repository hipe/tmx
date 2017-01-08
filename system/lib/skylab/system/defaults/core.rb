module Skylab::System

  class Services___::Defaults  # read [#001] #section-3 - the introduction to the def..

    # ->

      def initialize svx

        @__system_services = svx
      end

      Home_.lib_.attributes_stack_frame( self,

        :memoized, :inline_method, :cache_path, -> do

          # contrast with the tmp path, the difference is perhaps arbitrary

          fs = @__system_services.filesystem

          dir = ::File.join fs.tmpdir_path, CACHE_FILE__

          if ! fs.exist? dir
            fs.mkdir dir, 0766  # same perms as `TemporaryItems`
          end

          dir.freeze
        end,

        :memoized, :inline_method, :dev_tmpdir_path, -> do

          # sidesystems cannot assume that this directory *itself* exists,
          # but they must be able to assume that its *dirname* *does* exist.
          # we place the responsibility of ensuring *that* directory's
          # existence as outside of this scope (for now).
          #
          # permissions are a whole other issue that we sidestep dealing
          # with for now, assuming that the default permissions mask for
          # mkdir is the permissions of its parent, and the permissions of
          # the parent are outside our scope as stated.

          ::File.join( ::ENV.fetch( 'HOME' ), 'tmp', '__tmx_dev_tmpdir__' ).freeze
        end,
      )

      CACHE_FILE__ = 'sl.skylab'.freeze  # covered

      # <-
  end
end
