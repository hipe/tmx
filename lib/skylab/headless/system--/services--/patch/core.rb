module Skylab::Headless

  module System__

    class Services__::Patch

      # [#162] #open, will re-write to be an actor

      # using the host system's `patch` utility, apply a patch to a file or
      # directory on the filesystem given a string that contains the patch data.

      def directory patch_s, dir_path, dry_run, verbose, info_p
        Patch__[ patch_s, :dir, dir_path, dry_run, verbose, info_p ]
      end

      def file patch_s, file_path, dry_run, verbose, info_p
        Patch__[ patch_s, :file, file_path, dry_run, verbose, info_p ]
      end

      def new patch_content_x
        Patch_::Models__::ContentPatch.new patch_content_x
      end

      def models
        Patch_::Models__
      end

    Patch__ = -> patch_str, as, target_path, dry_run, verbose, info do
      res = nil
      cmd = [ 'patch' ]
      exec = -> do
        command = cmd * TERM_SEPARATOR_STRING_
        if dry_run
          info[ "#{ command } < -\n#{ patch_str }" ] if verbose
          break( res = 0 )
        end
        Headless_::Library_::Open3.popen3( command ) do |sin, sout, serr, w|
          sin.write patch_str
          sin.close
          s = serr.read
          if EMPTY_S_ != s
            raise "patch failed(?): #{ s.inspect }"
          end
          if verbose
            while s = sout.gets
              info[ s.strip ]
            end
          end
          res = w.value # exit_status
        end
        nil
      end
      case as
      when :dir
        cmd.push '-p1'
        fu = Headless_::IO.fu.new( verbose ? info : MONADIC_EMPTINESS_ )
        fu.cd target_path do
          exec[]
        end
      when :file
        cmd.push target_path
        exec[]
      end
      res
    end

      Patch_ = self
    end
  end
end
