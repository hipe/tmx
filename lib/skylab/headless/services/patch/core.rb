module Skylab::Headless
  module Services::Patch          # using the host system's `patch` utility,
                                  # patch a file on the filesystem given
                                  # a string that contains the patch data.

    extend MetaHell::Autoloader::Autovivifying::Recursive

    def self.call patch_content, from_dir, verbose, info
      fu = Headless::IO::FU.new( verbose ? info : -> _ { } )
      res = nil
      fu.cd from_dir do
        cmd_head = 'patch -p1'
        # info[ "#{ cmd_head } < -" ] if verbose
        Headless::Services::Open3.popen3( cmd_head ) do |sin, sout, serr, w|
          sin.write patch_content
          sin.close
          s = serr.read
          if '' != s
            raise "patch failed(?): #{ s.inspect }"
          end
          if verbose
            while s = sout.gets
              info[ s.strip ]
            end
          end
          res = w.value # exit_status
        end
      end
      res
    end
  end
end
