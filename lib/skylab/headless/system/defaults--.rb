module Skylab::Headless

  module System

    DEFAULTS__ = ( class Defaults___  # class for singleton pattern :+[#sl-126]

      # read [#140] the headless System narrative #section-3 - the introd..

      Headless_::Lib_::Properties_stack_frame.call self,

        :memoized, :proc, :bin_pathname, -> do
          ::Skylab.dir_pathname.join( '../../bin' ).expand_path
        end,

        :memoized, :proc, :cache_pathname, -> do
          pn = System.defaults.tmpdir_pathname.join CACHE_FILE__
          pn.exist? or ::Dir.mkdir pn.to_s, CACHE_PERMS__
          pn
        end,

        # ~ tmpdir paths

        :memoized, :inline_method, :dev_tmpdir_path, -> do
          dev_tmpdir_pathname.to_path.freeze
        end,

        :memoized, :proc, :dev_tmpdir_pathname, -> do
          ::Skylab.dir_pathname.join DEV_TMPDIR_PATH__
        end,

        :memoized, :inline_method, :tmpdir_path, -> do
          tmpdir_pathname.to_path.freeze
        end,

        :memoized, :proc, :tmpdir_pathname, -> do
          ::Pathname.new Headless::Library_::Tmpdir.tmpdir
        end

      CACHE_FILE__ = 'sl.skylab'.freeze
      CACHE_PERMS__ = 0766  # same perm as `TemporaryItems`
      DEV_TMPDIR_PATH__ = '../../tmp'.freeze  # [#128] this devil's work

      self
    end ).new
  end
end
