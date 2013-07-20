module Skylab::Git

  module API

    # for <somefile> 1) MOVE IT to a tempdir 2) git checkout HEAD <somefile>,
    # 3) move <somefile> to <somefile>.HEAD.ext 4) move from temp location back.

    class Actions::Head

      MetaHell::Funcy[ self ]
      MetaHell::FUN.fields[ self, :y, :path, :is_dry_run ]

      def execute
        r = -> do  # #result-block
          @fu = build_fu
          @pathname = ::Pathname.new @path
          @tdpn = ::Skylab::Subsystem::PATHNAMES.tmpdir
          @tpn = get_temp_pathname
          confirm_source_and_move or break false
          git_checkout_head or break false
          swap_back
        end.call
        if false == r
          @y << "(aborting for the above reasons)"
        else
          @y << "wrote #{ @tgt }"
        end
        r
      end

    private

      def build_fu
        Git::Services::Headless::IO::FU.new -> s do
          @y << "(#{ s })"
        end
      end

      def get_mutex_pathname
        @tdpn.join "#{ self.class.to_s.gsub( '::', '-' ).downcase }-mutex"
      end

      def get_temp_pathname
        pn = get_mutex_pathname ; num = nil
        pn.open 'a+'  do |fh|
          x = fh.read
          if '' == x
            @y << "(creating #{ pn })"
            num = 0
          else
            @y << "(reading #{ pn })"
            num = ( x.to_i + 1 )
          end
          fh.truncate 0
          fh.write num
        end
        @tdpn.join "HOLD-#{ num }#{ @pathname.extname }"
      end

      def confirm_source_and_move
        begin
          @is_dry_run and ! @pathname.exist? and raise_after = true
          @fu.move @pathname.to_s, @tpn.to_s, noop: @is_dry_run
          raise_after and raise Errno::ENOENT, @pathname.to_s
          true
        rescue Errno::ENOENT => e
          @y << "(got enoent error: #{ e.message })"
          false
        end
      end

      def git_checkout_head
        @pathname or fail "sanity"
        @pathname.directory? and fail "sanity"
        path = @pathname.to_s
        path.length.nonzero? or fail "sanity"
        cmd_a = [ 'git', 'checkout', 'HEAD', '--', path ]
        @y << "(running: #{ cmd_a * ' ' })"
        if @is_dry_run
          @y << "(with dry run, feigning success of above.)"
          out = err = '' ; status = 0
        else
          _, o, e, w = Git::Services::Open3.popen3( * cmd_a )
          out = o.read ; err = e.read ; status = w.value.exitstatus
        end
        if ( out.length + err.length ).nonzero?
          err.length.nonzero? and @y << "(git stderr msg: #{ err.chomp })"
          out.length.nonzero? and @y << "(git stdout msg: #{ out.chomp })"
          @y << "(got status from git: #{ status })"
          false
        elsif status.nonzero?
          @y << "(got nonzero exit status from git: #{ status }.)"
          false
        else
          true
        end
      end

      def swap_back
        path = @pathname.to_s
        a = @pathname.basename.sub_ext( '' ).to_s ; b = @pathname.extname
        @tgt = @pathname.dirname.join( "#{ a }.HEAD#{ b }" )
        @fu.move path, @tgt.to_s, noop: @is_dry_run
        @fu.move @tpn.to_s, path, noop: @is_dry_run
        true
      end
    end
  end
end
