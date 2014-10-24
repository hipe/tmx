module Skylab::Headless

  module System__

    class Services__::Defaults  # read [#140] #section-3 - the introduction to the def..

      def initialize x
        @system = x
      end

      Headless_::Lib_::Properties_stack_frame.call self,

        :memoized, :proc, :bin_pathname, -> do
          ::Skylab.dir_pathname.join( '../../bin' ).expand_path
        end,

        :memoized, :inline_method, :cache_pathname, -> do
          pn = @system.filesystem.tmpdir_pathname.join CACHE_FILE__
          pn.exist? or ::Dir.mkdir pn.to_s, CACHE_PERMS__
          pn
        end,

        # ~ tmpdir paths

        :memoized, :inline_method, :dev_tmpdir_path, -> do
          dev_tmpdir_pathname.to_path.freeze
        end,

        :memoized, :proc, :dev_tmpdir_pathname, -> do
          ::Skylab.dir_pathname.join DEV_TMPDIR_PATH__
        end

      CACHE_FILE__ = 'sl.skylab'.freeze
      CACHE_PERMS__ = 0766  # same perm as `TemporaryItems`
      DEV_TMPDIR_PATH__ = '../../tmp'.freeze  # [#128] this devil's work
    end
  end
end
