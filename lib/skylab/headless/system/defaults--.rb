module Skylab::Headless

  module System

    class Defaults__  # class for singleton pattern :+[#sl-126]

      # read [#140] the headless System narrative #section-3 - the introd..

      a = [ ]  # everything added to this list will become a memoized proc

      a << :tmpdir_path << -> do
        System.defaults.tmpdir_pathname.to_s.freeze
      end

      a << :tmpdir_pathname << -> do
        ::Pathname.new Headless::Library_::Tmpdir.tmpdir
      end

      a << :dev_tmpdir_path << -> do
        System.defaults::tmpdir_pathname.to_s.freeze
      end

      a << :dev_tmpdir_pathname << -> do
        ::Skylab.dir_pathname.join DEV_TMPDIR_PATH__
      end
      DEV_TMPDIR_PATH__ = '../../tmp'.freeze  # [#128] this devil's work

      a << :cache_pathname << -> do
        pn = System.defaults.tmpdir_pathname.join CACHE_FILE__
        pn.exist? or ::Dir.mkdir pn.to_s, CACHE_PERMS__
        pn
      end
      CACHE_FILE__ = 'sl.skylab'.freeze
      CACHE_PERMS__ = 0766  # same perm as `TemporaryItems`

      a << :bin_pathname << -> do
        ::Skylab.dir_pathname.join( '../../bin' ).expand_path
      end

      _MEMBER_I_A = nil
      a << :members << -> { _MEMBER_I_A }
      a.freeze
      _MEMBER_I_A = ( a.length / 2 ).times.map { |d| a[ d * 2 ] }.freeze


      MetaHell_::FUN::Fields_::Contoured_[ self,
        :overriding, :globbing, :absorber, :initialize,
        * ( _MEMBER_I_A.reduce [] do |m, i|
          m << :memoized << :proc << i
        end ) ]

      System::DEFAULTS__ = new( * a )
    end
  end
end
