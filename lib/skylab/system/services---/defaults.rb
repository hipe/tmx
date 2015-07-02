module Skylab::System


    class Services___::Defaults  # read [#140] #section-3 - the introduction to the def..

      def initialize svx

        @__sytem_services = svx
      end

      Home_.lib_.properties_stack_frame self,

        :memoized, :inline_method, :bin_path, -> do
          bin_pathname.to_path
        end,

        :memoized, :inline_method, :bin_pathname, -> do
          top_of_the_universe_pathname.join 'bin'
        end,

        :memoized, :inline_method, :cache_pathname, -> do
          pn = @__sytem_services.filesystem.tmpdir_pathname.join CACHE_FILE__
          pn.exist? or ::Dir.mkdir pn.to_s, 0766  # same perms as `TemporaryItems`
          pn
        end,


        # ~ tmpdir paths

        :memoized, :inline_method, :dev_tmpdir_path, -> do
          dev_tmpdir_pathname.to_path.freeze
        end,

        :memoized, :inline_method, :dev_tmpdir_pathname, -> do
          top_of_the_universe_pathname.join 'tmp'  # [#128] the devil's work
        end,


        # ~ doc-test related paths (for dev & hax)

        :memoized, :proc, :doc_test_manifest_file, -> do
          'doc-test.manifest'.freeze
        end,


        # ~ support

        :memoized, :proc, :top_of_the_universe_pathname, -> do
          ::Skylab.dir_pathname.join( '../..' ).expand_path
        end

        CACHE_FILE__ = 'sl.skylab'.freeze  # covered

    end
end
