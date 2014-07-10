module Skylab::Headless

  module Text::Patch          # using the host system's `patch` utility,
                                  # apply a patch to a file or directory on the
                                  # filesystem given
                                  # a string that contains the patch data.

    patch = -> patch_str, as, target_path, dry_run, verbose, info do
      res = nil
      cmd = [ 'patch' ]
      exec = -> do
        command = cmd * TERM_SEPARATOR_STRING_
        if dry_run
          info[ "#{ command } < -\n#{ patch_str }" ] if verbose
          break( res = 0 )
        end
        Headless::Library_::Open3.popen3( command ) do |sin, sout, serr, w|
          sin.write patch_str
          sin.close
          s = serr.read
          if EMPTY_STRING_ != s
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
        fu = Headless::IO::FU.new( verbose ? info : -> _ { } )
        fu.cd( target_path ) do exec[] end
      when :file
        cmd.push target_path
        exec[]
      end
      res
    end

    define_singleton_method :directory do
      |patch_str, dir_path, dry_run, verbose, info|
      patch[ patch_str, :dir, dir_path, dry_run, verbose, info ]
    end

    define_singleton_method :file do
      |patch_str, file_path, dry_run, verbose, info|
      patch[ patch_str, :file, file_path, dry_run, verbose, info ]
    end
  end
end
