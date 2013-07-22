module Skylab::Headless

  class System::Defaults_  # class for singleton [#sl-126]

    a = [ ]  # ( everything added to this list will become a memoized proc )

    a << :tmpdir_path << -> do
      System.defaults.tmpdir_pathname.to_s.freeze  # we get memoized
    end

    a << :tmpdir_pathname << -> do
      ::Pathname.new Headless::Services::Tmpdir.tmpdir
    end

    a << :dev_tmpdir_path << -> do
      System.defaults::tmpdir_pathname.to_s.freeze  # we get memoized
    end

    a << :dev_tmpdir_pathname << -> do
      ::Skylab.dir_pathname.join DEV_TMPDIR_PATH_
    end
    DEV_TMPDIR_PATH_ = '../../tmp'.freeze  # [#128]

    a << :cache_pathname << -> do  # experimentally for caching things in
      # production - it should only be used with the utmost OCD-fueled hyper-
      # extreme caution and over-engineering you can muster, because nothing
      # puts a turd in your easter basket worse than an epic bughunt caused by
      # a stale cache save for actually experiencing that.

      pn = System.defaults.tmpdir_pathname.join CACHE_FILE_
      pn.exist? or ::Dir.mkdir pn.to_s, CACHE_PERMS_
      pn
    end
    CACHE_FILE_ = 'sl.skylab'.freeze
    CACHE_PERMS_ = 0766  # perms of `TemporaryItems`

    a << :members << -> { MEMBER_A_ }
    DEFAULTS_A_ = a.freeze
    MEMBER_A_ = ( a.length / 2 ).times.map { |d| a[ d * 2 ] }.freeze  # eew sorry

    MetaHell::FUN::Fields_::Contoured_[ self, *
      ( MEMBER_A_.reduce [] do |m, i|
        m << :memoized << :proc << i
      end ) ]
  end

  module System

    DEFAULTS_ =  Defaults_.new( * Defaults_::DEFAULTS_A_ )

  end
end
