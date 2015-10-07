module Skylab::System

  class Services___::Defaults  # read [#001] #section-3 - the introduction to the def..

    # ->

      def initialize svx

        @__system_services = svx
      end

      Home_.lib_.properties_stack_frame self,

        :memoized, :inline_method, :cache_pathname, -> do
          ::Pathname.new cache_path
        end,

        :memoized, :inline_method, :cache_path, -> do

          fs = @__system_services.filesystem

          dir = ::File.join fs.tmpdir_path, CACHE_FILE__

          if ! fs.exist? dir
            fs.mkdir dir, 0766  # same perms as `TemporaryItems`
          end

          dir
        end,


        # ~ tmpdir paths

        :memoized, :inline_method, :dev_tmpdir_path, -> do
          dev_tmpdir_pathname.to_path.freeze
        end,

        :memoized, :inline_method, :dev_tmpdir_pathname, -> do
          ::Pathname.new( ::File.join ::ENV.fetch( 'HOME' ), 'tmp' )
          # [#128] the devil's work
        end,


        # ~ doc-test related paths (for dev & hax)

        :memoized, :proc, :doc_test_manifest_file, -> do
          'doc-test.manifest'.freeze
        end




        CACHE_FILE__ = 'sl.skylab'.freeze  # covered

      # <-
  end
end
