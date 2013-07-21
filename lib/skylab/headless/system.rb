module Skylab::Headless

  module System

    # provides system reflection and environment info in a zero-configuration
    # manner, e.g things like where a cache dir or a temp dir that can be
    # used is, for whatever specific system we are running on.
    #
    # the whole premise of this node is dubious; but its implementation is so
    # neato that it makes it worth it. at worst it puts tracking leashes on
    # all of its uses throughout the system until we figure out what the
    # 'Right Way' is.

    a = [ ]  # ( everything added to this list will become a memoized proc )

    define_singleton_method :defaults do
      if const_defined? :DEFAULTS_, false
        const_get :DEFAULTS_, false
      else
        const_set :DEFAULTS_, Defaults_.new( * a )
      end
    end

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

    a << :members << -> { MEMBER_A }
    a.freeze
    MEMBER_A_ = ( a.length / 2 ).times.map { |d| a[ d * 2 ] }.freeze  # eew sorry

    class Defaults_  # class for singleton [#126]
      MetaHell::FUN::Fields_::Contoured_[ self, *
        ( MEMBER_A_.reduce [] do |m, i|
          m << :memoized << :proc << i
        end ) ]
    end

    module InstanceMethods
    private
      def system
        @system ||= System::Client.new
      end
    end

    class Client
      # because singletons are bad for testing
      def which exe_name
        /\A[-a-z0-9_]+\z/i =~ exe_name or raise "invalid name: #{ exe_name }"
        out = nil
        Headless::Services::Open3.popen3 'which', exe_name do |_, sout, serr|
          if '' != ( err = serr.read )
            raise ::SystemCallError, "unexpected response from which - #{ err }"
          end
          out = sout.read.strip
        end
        '' == out ? nil : out
      end
      def members
        InstanceMethods.instance_methods
      end
    end
  end
end
